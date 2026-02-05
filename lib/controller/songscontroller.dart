import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/function/find_current_index.dart';
import 'package:musiclotm/core/function/song_to_media_item.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Songscontroller extends GetxController {
  // Get dependencies
  AnimationControllerX get animationController =>
      Get.find<AnimationControllerX>();

  final OnAudioQuery onAudioQuery = OnAudioQuery();
  final ItemScrollController itemScrollController = ItemScrollController();

  // Observables
  RxBool isplaylist = false.obs;
  RxBool isfavorite = false.obs;
  RxBool isallmusic = true.obs;
  RxBool issearch = true.obs;
  RxBool isLoading = false.obs;
  RxBool haspermission = false.obs;
  RxList<MediaItem> songs = <MediaItem>[].obs;
  RxInt currentSongPlayingIndex = 0.obs;

  // State
  String? sortypeallMusic;
  String? sortypePlaylists;
  String? sortypeFavorite;
  int position = 0;
  List<SongModel> songModels = [];

  // Loading control
  bool _isLoading = false;
  Completer<void>? _loadCompleter;

  Future<void> handleAllSongs() async {
    if (songs.isNotEmpty) {
      try {
        await songHandler.initSongs(songs: songs);
      } catch (e) {
        log('Error initializing songs: $e');
        Get.snackbar('Error', 'Failed to initialize songs');
      }
    }
  }

  Future<List<MediaItem>> getSongs() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final effectiveSortType = audioQuerySongSortType(
        sortypeallMusic ?? "titleASC",
      );
      final effectiveOrderType = audioQueryOrderType(
        sortypeallMusic ?? "titleASC",
      );

      songModels = await onAudioQuery.querySongs(
        sortType: effectiveSortType,
        orderType: effectiveOrderType,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // FIX: Better filtering
      songModels.removeWhere(
        (song) =>
            song.data.isEmpty ||
            song.title.isEmpty ||
            song.duration == null ||
            song.duration! <= 2000,
      );

      const chunkSize = 20;
      final List<MediaItem> result = [];

      for (int i = 0; i < songModels.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, songModels.length);
        final chunk = songModels.sublist(i, end);

        final processedChunk = await Future.wait(
          chunk.map((song) async {
            try {
              return await songToMediaItem(song);
            } catch (e) {
              log('Error converting song ${song.title}: $e');
              return null;
            }
          }),
        );

        result.addAll(processedChunk.whereType<MediaItem>());

        await Future.delayed(Duration.zero);
      }

      log(
        'Loaded ${result.length} valid songs out of ${songModels.length} total',
      );
      return result;
    } catch (e) {
      log('Error fetching songs: $e');
      Get.snackbar('Error', 'Failed to load songs: ${e.toString()}');
      return <MediaItem>[];
    }
  }

  Future<void> loadSongs() async {
    if (_isLoading) {
      await _loadCompleter?.future;
      return;
    }

    _isLoading = true;
    isLoading.value = true;
    _loadCompleter = Completer<void>();

    try {
      songs.clear();
      final fetchedSongs = await getSongs();

      if (fetchedSongs.isNotEmpty) {
        songs.assignAll(fetchedSongs);

        await Future.delayed(const Duration(milliseconds: 300));
        await handleAllSongs();
      } else {
        log('No songs found');
      }
    } catch (e) {
      log('Error loading songs: $e');
      Get.snackbar(
        'Error',
        'Failed to load songs: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      _isLoading = false;
      _loadCompleter?.complete();
      _loadCompleter = null;
    }
  }

  void scrollToCurrentSong() {
    if (songs.isEmpty || !itemScrollController.isAttached) return;

    int targetIndex;
    final currentMediaItem = songHandler.mediaItem.value;

    if (currentMediaItem == null) {
      targetIndex = 0;
    } else {
      targetIndex = songs.indexWhere((item) => item.id == currentMediaItem.id);
      if (targetIndex == -1) targetIndex = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        itemScrollController.scrollTo(
          index: targetIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        log('Error scrolling to index $targetIndex: $e');
      }
    });
  }

  void updateSortType(String type) {
    sortypeallMusic = type;
    box.put("sortTypeAllMusic", type);
    loadSongs();
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadState();
      await checkPermissionAndLoad();
    } catch (e) {
      log('Error initializing SongsController: $e');
    }
  }

  Future<void> _loadState() async {
    try {
      position = box.get("position", defaultValue: 0) ?? 0;
      currentSongPlayingIndex.value =
          box.get("currentIndex", defaultValue: 0) ?? 0;
      isplaylist.value = box.get("isplaylist", defaultValue: false) ?? false;
      isfavorite.value = box.get("isfavorite", defaultValue: false) ?? false;
      isallmusic.value = box.get("isallmusic", defaultValue: true) ?? true;

      sortypeallMusic =
          box.get("sortTypeAllMusic", defaultValue: "titleASC") ?? "titleASC";
      sortypeFavorite =
          box.get("sortTypeFavorite", defaultValue: "titleASC") ?? "titleASC";
      sortypePlaylists =
          box.get("sortTypePlaylists", defaultValue: "titleASC") ?? "titleASC";

      log('Loaded sort type: $sortypeallMusic');
    } catch (e) {
      log('Error loading state: $e');
    }
  }

  // songscontroller.dart

  Future<void> checkPermissionAndLoad() async {
    // 1. Check current status
    bool audioGranted = await Permission.audio.isGranted;
    bool storageGranted = await Permission.storage.isGranted;

    if (audioGranted || storageGranted) {
      haspermission.value = true;
      await loadSongs();
    } else {
      log("User denied permissions.");
      Get.snackbar(
        'Permission Required',
        'Please grant storage access to see your music.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

void refreshCurrentSongIndex() {
  final currentMediaItem = songHandler.mediaItem.value;
  if (currentMediaItem != null) {
    CurrentSongIndexFinder.findAndUpdateCurrentIndex(currentMediaItem.id);
  }
}
// Add these methods to your Songscontroller class

Future<void> addSongToPlaylist(MediaItem song, String playlistId) async {
  final playlistController = Get.find<Playlistcontroller>();
  await playlistController.addSongToPlaylist(
    playlistId: playlistId,
    songId: song.id,
  );
}

Future<void> addCurrentSongToPlaylist(String playlistId) async {
  final currentSong = songHandler.mediaItem.value;
  if (currentSong != null) {
    await addSongToPlaylist(currentSong, playlistId);
  }
}
