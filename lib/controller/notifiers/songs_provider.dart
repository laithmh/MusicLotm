import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/services/song_to_media_item.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

RxBool haspermission = false.obs;

class Songscontroller extends GetxController {
  final StreamController<RxList<MediaItem>> myStreamController =
      StreamController<RxList<MediaItem>>();
  Stream<RxList<MediaItem>> get myStream => myStreamController.stream;
  List<SongModel> songModels = [];
  RxList<MediaItem> songs = <MediaItem>[].obs;
  RxInt currentSongPlayingIndex = 0.obs;

  Future<void> requestSongPermission() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
        Permission.scheduleExactAlarm,
      ].request();

      if (statuses[Permission.storage]!.isGranted ||
          statuses[Permission.audio]!.isGranted) {
        await loadSongs(songHandler);
        haspermission.value = statuses[Permission.storage]!.isGranted;
      } else {
        await openAppSettings();

        log('Permission not granted. Please enable storage access.');
      }
    } catch (e) {
      debugPrint('Error requesting song permissions: $e');
    }
  }

  handelallsongs() async {
    await songHandler.initSongs(songs: songs);
  }

  void findCurrentSongPlayingIndex(String songId) {
    var index = 0;
    for (var e in songs) {
      if (e.id == songId) {
        currentSongPlayingIndex.value = index;
      }

      index++;
    }
  }

  Future<RxList<MediaItem>> getSongs() async {
    try {
      final OnAudioQuery onAudioQuery = OnAudioQuery();

      songModels = await onAudioQuery.querySongs();

      // for (final SongModel songModel in songModels) {
      //   final MediaItem song = await songToMediaItem(songModel);
      //   songs.add(song);
      //   myStreamController.add(songs);
      // }
      songs.value = await Future.wait(songModels.map((song) async {
        return songToMediaItem(song);
      }).toList());
      myStreamController.add(songs);
      return songs;
    } catch (e) {
      debugPrint('Error fetching songs: $e');
      return <MediaItem>[].obs;
    }
  }

  Future<void> loadSongs(SongHandler songHandler) async {
    try {
      songs = await getSongs();

      await songHandler.initSongs(songs: songs);

      update();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  @override
  void onInit() async {
    await requestSongPermission();
    super.onInit();
  }

  @override
  void onClose() {
    myStreamController.close();
    super.onClose();
  }
}
