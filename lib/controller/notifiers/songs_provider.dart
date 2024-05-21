import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/services/song_to_media_item.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

RxBool haspermission = false.obs;

class Songscontroller extends GetxController {
  // Playlistcontroller playlistcontroller = Get.put(Playlistcontroller());
  late RxBool isplaylist = false.obs;
  late RxBool isfavorite = false.obs;
  late RxBool isallmusic = true.obs;

  late int position = 0;
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

  Future<RxList<MediaItem>> getSongs() async {
    try {
      final OnAudioQuery onAudioQuery = OnAudioQuery();

      songModels = await onAudioQuery.querySongs();

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

      update();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  @override
  void onInit() async {
    position = await box.get("position");
    currentSongPlayingIndex.value = await box.get("currentIndex");
    isplaylist.value = await box.get("isplaylist");
    isfavorite.value = await box.get("isfavorite");
    isallmusic.value = await box.get("isallmusic");
    log("==========");

    super.onInit();
  }

  @override
  void onClose() {
    myStreamController.close();
    super.onClose();
  }
}

void findCurrentSongPlayingIndex(String songId) {
 Songscontroller controller = Get.find();
 Playlistcontroller playlistcontroller = Get.find();
  int index = 0;
  if (controller. isallmusic.isTrue) {
    for (var e in controller. songs) {
      if (e.id == songId) {
       controller. currentSongPlayingIndex.value = index;
      }

      index++;
    }
  } else if (controller. isplaylist.isTrue) {
    for (var e in playlistcontroller.mediasongs) {
      if (e.id == songId) {
        controller. currentSongPlayingIndex.value = index;
      }
      

      index++;
    }
  } else if (controller. isfavorite.isTrue) {
    for (var e in playlistcontroller.favorites) {
      if (e.id == songId) {
       controller.  currentSongPlayingIndex.value = index;
      }
      
      index++;
    }
  }

  box.put("currentIndex",controller.  currentSongPlayingIndex.value);
}
