import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/function/find_current_index.dart';
import 'package:musiclotm/core/function/permission.dart';
import 'package:musiclotm/core/function/song_to_media_item.dart';
import 'package:musiclotm/core/function/sort.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Songscontroller extends GetxController {
  // Get dependencies
  AnimationControllerX get animationController =>
      Get.find<AnimationControllerX>();

  final OnAudioQuery onAudioQuery = OnAudioQuery();
  final ItemScrollController itemScrollController = ItemScrollController();
  late Box box;
  SongHandler songHandler = Get.find<SongHandler>();
  
  // Observables
  RxBool isplaylist = false.obs;
  RxBool isfavorite = false.obs;
  RxBool isallmusic = true.obs;
  RxBool issearch = true.obs;
  RxBool isLoading = false.obs;
  RxBool haspermission = false.obs;
  RxList<MediaItem> songs = <MediaItem>[].obs;
  RxInt currentSongPlayingIndex = 0.obs;
Rx<MediaItem?> currentMediaItem = Rx<MediaItem?>(null);
  // Sorting
  RxString sortTypeAllMusic = "titleASC".obs;
  RxString sortTypePlaylists = "titleASC".obs;
  RxString sortTypeFavorite = "titleASC".obs;
  
  // State
  int position = 0;
  List<SongModel> songModels = [];

  // Loading control
  Completer<void>? _loadCompleter;

  Future<void> handleAllSongs({bool restoreState = true}) async {
    if (songs.isNotEmpty) {
      try {
        await songHandler.initSongs(
          songs: songs,
          restoreState: restoreState,
        );
      } catch (e) {
        log('Error initializing songs: $e');
        Get.snackbar('Error', 'Failed to initialize songs');
      }
    }
  }

  Future<List<MediaItem>> getSongs({String? customSortType}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final String sortType = customSortType ?? sortTypeAllMusic.value;
      final effectiveSortType = audioQuerySongSortType(sortType);
      final effectiveOrderType = audioQueryOrderType(sortType);

      log('Fetching songs with sort type: $sortType');
      
      songModels = await onAudioQuery.querySongs(
        sortType: effectiveSortType,
        orderType: effectiveOrderType,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filter invalid songs
      songModels.removeWhere(
        (song) =>
            song.data.isEmpty ||
            song.title.isEmpty ||
            song.duration == null ||
            song.duration! <= 2000, // Remove songs shorter than 2 seconds
      );

      // Process songs in chunks to avoid UI freeze
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

        // Allow UI to update between chunks
        await Future.delayed(Duration.zero);
      }

      log('Loaded ${result.length} valid songs out of ${songModels.length} total');
      return result;
    } catch (e) {
      log('Error fetching songs: $e');
      Get.snackbar(
        'Error',
        'Failed to load songs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return <MediaItem>[];
    }
  }

  Future<void> loadSongs({bool restoreState = true, String? sortType}) async {
    if (isLoading.value) {
      await _loadCompleter?.future;
      return;
    }

    isLoading.value = true;
    _loadCompleter = Completer<void>();

    try {
      // Clear current songs
      songs.clear();
      
      // Get songs with optional sort type
      final fetchedSongs = await getSongs(customSortType: sortType);

      if (fetchedSongs.isNotEmpty) {
        songs.assignAll(fetchedSongs);

        // Initialize song handler with state restoration
        await Future.delayed(const Duration(milliseconds: 300));
        await handleAllSongs(restoreState: restoreState);

        // Scroll to current song if in all music view
        if (isallmusic.value) {
          scrollToCurrentSong();
        }
      } else {
        log('No songs found');
        Get.snackbar(
          'No Songs',
          'No music files found on your device',
          snackPosition: SnackPosition.BOTTOM,
        );
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
      _loadCompleter?.complete();
      _loadCompleter = null;
    }
  }

  Future<void> reloadSongs() async {
    await loadSongs(restoreState: false);
  }

  void scrollToCurrentSong() {
    if (songs.isEmpty || !itemScrollController.isAttached) return;

    int targetIndex;
    final currentMediaItem = songHandler.mediaItem.value;

    if (currentMediaItem == null) {
      targetIndex = 0;
    } else {
      // Find the current song in our list
      targetIndex = songs.indexWhere((item) => item.id == currentMediaItem.id);
      if (targetIndex == -1) {
        log('Current song not found in list');
        targetIndex = 0;
      }
    }

    // Scroll after a delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!itemScrollController.isAttached) return;
      
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
    if (isallmusic.value) {
      sortTypeAllMusic.value = type;
      box.put("sortTypeAllMusic", type);
    } else if (isfavorite.value) {
      sortTypeFavorite.value = type;
      box.put("sortTypeFavorite", type);
    } else if (isplaylist.value) {
      sortTypePlaylists.value = type;
      box.put("sortTypePlaylists", type);
    }
    
    // Reload songs with new sort type
    loadSongs(sortType: type);
  }

  String getCurrentSortType() {
    if (isallmusic.value) {
      return sortTypeAllMusic.value;
    } else if (isfavorite.value) {
      return sortTypeFavorite.value;
    } else if (isplaylist.value) {
      return sortTypePlaylists.value;
    }
    return "titleASC";
  }

  @override
  void onInit() {
    super.onInit();
    box = Hive.box("music");
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadSavedState();
      await checkPermissionAndLoad();
    } catch (e) {
      log('Error initializing SongsController: $e');
    }
  }

  Future<void> _loadSavedState() async {
    try {
      // Load position
      position = box.get("position", defaultValue: 0);
      
      // Load current song index
      currentSongPlayingIndex.value = box.get("currentIndex", defaultValue: 0);
      
      // Load view states
      isplaylist.value = box.get("isplaylist", defaultValue: false);
      isfavorite.value = box.get("isfavorite", defaultValue: false);
      isallmusic.value = box.get("isallmusic", defaultValue: true);
      
      // Load sort types
      sortTypeAllMusic.value = box.get("sortTypeAllMusic", defaultValue: "titleASC");
      sortTypeFavorite.value = box.get("sortTypeFavorite", defaultValue: "titleASC");
      sortTypePlaylists.value = box.get("sortTypePlaylists", defaultValue: "titleASC");
      
      // Save loaded sort types back to ensure consistency
      box.put("sortTypeAllMusic", sortTypeAllMusic.value);
      box.put("sortTypeFavorite", sortTypeFavorite.value);
      box.put("sortTypePlaylists", sortTypePlaylists.value);
      
      log('Loaded state - AllMusic: ${sortTypeAllMusic.value}, Favorite: ${sortTypeFavorite.value}, Playlists: ${sortTypePlaylists.value}');
    } catch (e) {
      log('Error loading state: $e');
    }
  }

  Future<void> checkPermissionAndLoad() async {
    // Check and request permissions
    bool status = await requestInitialPermissions();
    
    if (status) {
      haspermission.value = true;
      await loadSongs(restoreState: true);
    } else {
      haspermission.value = false;
      log("User denied storage permission.");
      
      Get.snackbar(
        'Permission Required',
        'Please grant storage access to see your music.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text('Open Settings'),
        ),
      );
    }
  }

  Future<void> requestPermission() async {
    await checkPermissionAndLoad();
  }

  void refreshCurrentSongIndex() {
    final currentMediaItem = songHandler.mediaItem.value;
    if (currentMediaItem != null) {
      CurrentSongIndexFinder.findAndUpdateCurrentIndex(currentMediaItem.id);
    }
  }

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

  Future<void> switchToAllMusic() async {
    isallmusic.value = true;
    isplaylist.value = false;
    isfavorite.value = false;
    
    // Save state
    box.put("isallmusic", true);
    box.put("isplaylist", false);
    box.put("isfavorite", false);
    
    // Reload with saved state restoration
    await loadSongs(restoreState: true);
  }

  Future<void> switchToFavorites() async {
    isallmusic.value = false;
    isplaylist.value = false;
    isfavorite.value = true;
    
    // Save state
    box.put("isallmusic", false);
    box.put("isplaylist", false);
    box.put("isfavorite", true);
    
    // Note: You'll need to load favorite songs here
    // await loadFavoriteSongs();
  }

  Future<void> switchToPlaylist() async {
    isallmusic.value = false;
    isplaylist.value = true;
    isfavorite.value = false;
    
    // Save state
    box.put("isallmusic", false);
    box.put("isplaylist", true);
    box.put("isfavorite", false);
    
    // Note: You'll need to load playlist songs here
    // await loadPlaylistSongs();
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      // Reset to original list
      await loadSongs();
      return;
    }

    isLoading.value = true;
    
    try {
      final lowerQuery = query.toLowerCase();
      final filteredSongs = await getSongs();
      
      final filtered = filteredSongs.where((song) {
        return song.title.toLowerCase().contains(lowerQuery) ||
               song.artist?.toLowerCase().contains(lowerQuery) == true ||
               song.album?.toLowerCase().contains(lowerQuery) == true;
      }).toList();

      songs.assignAll(filtered);
      
      // Initialize with filtered songs but don't restore state for search
      await songHandler.updatequeue(filtered);
    } catch (e) {
      log('Error searching songs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get current playing state for UI
  Map<String, dynamic> getCurrentPlayingState() {
    return {
      'currentSong': songHandler.mediaItem.value?.title ?? 'No song playing',
      'currentIndex': songHandler.audioPlayer.currentIndex ?? 0,
      'isPlaying': songHandler.audioPlayer.playing,
      'isLooping': songHandler.isloop.value,
      'isShuffling': songHandler.isShuffel.value,
    };
  }

  // Clear all saved states
  Future<void> clearAllSavedStates() async {
    try {
      // Clear song handler state
      await songHandler.clearSavedState();
      
      // Clear controller state
      box.delete("position");
      box.delete("currentIndex");
      box.delete("isplaylist");
      box.delete("isfavorite");
      box.delete("isallmusic");
      
      log('All saved states cleared');
    } catch (e) {
      log('Error clearing saved states: $e');
    }
  }

  @override
  void onClose() {
    // Save current state before closing
    _saveCurrentState();
    super.onClose();
  }

  void _saveCurrentState() {
    try {
      // Save current view state
      box.put("isplaylist", isplaylist.value);
      box.put("isfavorite", isfavorite.value);
      box.put("isallmusic", isallmusic.value);
      
      // Save sort types
      box.put("sortTypeAllMusic", sortTypeAllMusic.value);
      box.put("sortTypeFavorite", sortTypeFavorite.value);
      box.put("sortTypePlaylists", sortTypePlaylists.value);
      
      log('State saved on close');
    } catch (e) {
      log('Error saving state on close: $e');
    }
  }
}