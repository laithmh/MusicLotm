import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/services/request_song_permission.dart';
import 'package:musiclotm/core/services/song_to_media_item.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Songscontroller extends GetxController {
  final StreamController<RxList<MediaItem>> myStreamController =
      StreamController<RxList<MediaItem>>();

  Stream<RxList<MediaItem>> get myStream => myStreamController.stream;

  RxList<MediaItem> songs = <MediaItem>[].obs;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<RxList<MediaItem>> getSongs() async {
    try {
      await requestSongPermission();

      final OnAudioQuery onAudioQuery = OnAudioQuery();

      final List<SongModel> songModels = await onAudioQuery.querySongs();

      for (final SongModel songModel in songModels) {
        final MediaItem song = await songToMediaItem(songModel);
        songs.add(song);
        myStreamController.add(songs);
      }

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

      _isLoading = false;

      update();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  @override
  void onInit() async {
    await loadSongs(songHandler);
    super.onInit();
  }

  @override
  void onClose() {
    myStreamController.close();
    super.onClose();
  }
}
