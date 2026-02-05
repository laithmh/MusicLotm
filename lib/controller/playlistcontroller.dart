import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/core/model/playlist_model.dart';
import 'package:musiclotm/core/service/playlist_service.dart';
import 'package:musiclotm/main.dart';

class Playlistcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  AnimationControllerX animationController = Get.find();

  final TextEditingController playlistNameController = TextEditingController();
  final TextEditingController playlistDescriptionController =
      TextEditingController();

  RxList<MediaItem> favorites = <MediaItem>[].obs;
  RxBool favoriteUpdated = false.obs;

  Map<dynamic, dynamic> isfavorite = {};
  // Observables
  RxList<AppPlaylist> playlists = <AppPlaylist>[].obs;
  RxList<MediaItem> currentPlaylistSongs = <MediaItem>[].obs;
  RxString currentPlaylistId = ''.obs;
  RxBool isLoading = false.obs;

  // Selection
  final RxList<String> selectedSongIds = <String>[].obs;
  final RxList<String> selectedPlaylistIds = <String>[].obs;
  RxBool isSelectionMode = false.obs;

  // Search
  RxString searchQuery = ''.obs;

  @override
  void onInit() async {
    super.onInit();

    await loadFavoritesFromHive();

    await loadAppPlaylists();
    await loadFavorites();
  }

  @override
  void onClose() {
    playlistNameController.dispose();
    playlistDescriptionController.dispose();
    super.onClose();
  }

  /// Load favorite map from Hive
  Future<void> loadFavoriteMap() async {
    try {
      final favoriteMap = box.get("favorite");
      if (favoriteMap != null && favoriteMap is Map) {
        isfavorite = Map<String, bool>.from(favoriteMap);
        log('❤️ Loaded ${isfavorite.length} favorites from storage');
      }
    } catch (e) {
      log('❌ Error loading favorites map: $e');
    }
  }

  /// Load app-specific playlists
  Future<void> loadAppPlaylists() async {
    try {
      isLoading.value = true;
      playlists.assignAll(AppPlaylistService.getAllPlaylists());
      log('📂 Loaded ${playlists.length} app playlists');
    } catch (e) {
      log('❌ Error loading app playlists: $e');
      Get.snackbar('Error', 'Failed to load playlists');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new playlist
  Future<AppPlaylist?> createNewPlaylist({
    String? name,
    String? description,
    List<String>? initialSongs,
  }) async {
    try {
      final playlistName = name?.trim() ?? playlistNameController.text.trim();
      if (playlistName.isEmpty) {
        Get.snackbar('Error', 'Playlist name cannot be empty');
        return null;
      }

      final playlist = await AppPlaylistService.createPlaylist(
        name: playlistName,
        description: description ?? playlistDescriptionController.text.trim(),
        initialSongs: initialSongs,
      );

      // Add to local list
      playlists.insert(0, playlist);

      // Clear controllers
      playlistNameController.clear();
      playlistDescriptionController.clear();

      Get.snackbar('Success', 'Playlist "$playlistName" created!');
      return playlist;
    } catch (e) {
      log('❌ Error creating playlist: $e');
      Get.snackbar('Error', 'Failed to create playlist');
      return null;
    }
  }

  /// Delete playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await AppPlaylistService.deletePlaylist(playlistId);
      playlists.removeWhere((p) => p.id == playlistId);

      // If deleted playlist is currently viewed, clear it
      if (currentPlaylistId.value == playlistId) {
        currentPlaylistId.value = '';
        currentPlaylistSongs.clear();
      }

      Get.snackbar('Success', 'Playlist deleted');
    } catch (e) {
      log('❌ Error deleting playlist: $e');
      Get.snackbar('Error', 'Failed to delete playlist');
    }
  }

  /// Load songs for a specific playlist
  Future<void> loadPlaylistSongs(String playlistId) async {
    try {
      isLoading.value = true;
      currentPlaylistId.value = playlistId;

      final playlist = AppPlaylistService.getPlaylist(playlistId);
      if (playlist == null) {
        currentPlaylistSongs.clear();
        return;
      }

      // Get all available songs
      final allSongs = songscontroller.songs;

      // Filter songs that are in this playlist
      final playlistSongIds = playlist.songIds;
      final filteredSongs = allSongs.where((song) {
        return playlistSongIds.contains(song.id);
      }).toList();

      // Sort if needed
      final sortedSongs = sort(
        song: filteredSongs,
        sortType: songscontroller.sortypePlaylists ?? 'titleASC',
      );

      currentPlaylistSongs.assignAll(sortedSongs);
      log(
        '🎵 Loaded ${filteredSongs.length} songs for playlist: ${playlist.name}',
      );
    } catch (e) {
      log('❌ Error loading playlist songs: $e');
      Get.snackbar('Error', 'Failed to load playlist songs');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
    bool showNotification = true,
  }) async {
    try {
      final success = await AppPlaylistService.addSongToPlaylist(
        playlistId: playlistId,
        songId: songId,
      );

      if (success) {
        // Update local state if this playlist is currently viewed
        if (currentPlaylistId.value == playlistId) {
          await loadPlaylistSongs(playlistId);
        }

        if (showNotification) {
          Get.snackbar('Success', 'Song added to playlist');
        }
      }
    } catch (e) {
      log('❌ Error adding song to playlist: $e');
      if (showNotification) {
        Get.snackbar('Error', 'Failed to add song to playlist');
      }
    }
  }

  /// Remove song from playlist
  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final success = await AppPlaylistService.removeSongFromPlaylist(
        playlistId: playlistId,
        songId: songId,
      );

      if (success) {
        // Update local state
        if (currentPlaylistId.value == playlistId) {
          currentPlaylistSongs.removeWhere((song) => song.id == songId);
        }

        Get.snackbar('Success', 'Song removed from playlist');
      }
    } catch (e) {
      log('❌ Error removing song from playlist: $e');
      Get.snackbar('Error', 'Failed to remove song from playlist');
    }
  }

  /// Add multiple songs to playlist
  Future<void> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    try {
      final success = await AppPlaylistService.addSongsToPlaylist(
        playlistId: playlistId,
        songIds: songIds,
      );

      if (success) {
        if (currentPlaylistId.value == playlistId) {
          await loadPlaylistSongs(playlistId);
        }

        Get.snackbar('Success', '${songIds.length} songs added to playlist');
      }
    } catch (e) {
      log('❌ Error adding songs to playlist: $e');
      Get.snackbar('Error', 'Failed to add songs to playlist');
    }
  }

  /// Clear playlist
  Future<void> clearPlaylist(String playlistId) async {
    try {
      final success = await AppPlaylistService.clearPlaylist(playlistId);

      if (success) {
        if (currentPlaylistId.value == playlistId) {
          currentPlaylistSongs.clear();
        }

        Get.snackbar('Success', 'Playlist cleared');
      }
    } catch (e) {
      log('❌ Error clearing playlist: $e');
      Get.snackbar('Error', 'Failed to clear playlist');
    }
  }

  /// Rename playlist
  Future<void> renamePlaylist({
    required String playlistId,
    required String newName,
  }) async {
    try {
      final playlist = AppPlaylistService.getPlaylist(playlistId);
      if (playlist == null) return;

      playlist.updateName(newName);
      await AppPlaylistService.updatePlaylist(playlist);

      // Update local list
      final index = playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        playlists[index] = playlist;
      }

      Get.snackbar('Success', 'Playlist renamed to "$newName"');
    } catch (e) {
      log('❌ Error renaming playlist: $e');
      Get.snackbar('Error', 'Failed to rename playlist');
    }
  }

  /// Handle playlist playback
  Future<void> handlePlaylist(String playlistId) async {
    try {
      await loadPlaylistSongs(playlistId);

      if (currentPlaylistSongs.isNotEmpty) {
        await songHandler.initSongs(songs: currentPlaylistSongs);
        animationController.reset();
        Get.snackbar('Playing', 'Playlist loaded');
      } else {
        Get.snackbar('Info', 'Playlist is empty');
      }
    } catch (e) {
      log('❌ Error handling playlist playback: $e');
      Get.snackbar('Error', 'Failed to play playlist');
    }
  }

  /// Search playlists
  void searchPlaylists(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      loadAppPlaylists();
    } else {
      final results = AppPlaylistService.searchPlaylists(query);
      playlists.assignAll(results);
    }
  }

  /// Selection mode methods
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      clearSelections();
    }
  }

  void selectSong(String songId) {
    if (selectedSongIds.contains(songId)) {
      selectedSongIds.remove(songId);
    } else {
      selectedSongIds.add(songId);
    }
  }

  void selectPlaylist(String playlistId) {
    if (selectedPlaylistIds.contains(playlistId)) {
      selectedPlaylistIds.remove(playlistId);
    } else {
      selectedPlaylistIds.add(playlistId);
    }
    update();
  }

  void clearSelections() {
    selectedSongIds.clear();
    selectedPlaylistIds.clear();
  }

  /// Add selected songs to selected playlists
  Future<void> addSelectedSongsToSelectedPlaylists() async {
    if (selectedSongIds.isEmpty || selectedPlaylistIds.isEmpty) {
      Get.snackbar('Info', 'Please select songs and playlists first');
      return;
    }

    try {
      for (final playlistId in selectedPlaylistIds) {
        await AppPlaylistService.addSongsToPlaylist(
          playlistId: playlistId,
          songIds: selectedSongIds,
        );
      }

      clearSelections();
      isSelectionMode.value = false;

      Get.snackbar(
        'Success',
        'Added ${selectedSongIds.length} songs to ${selectedPlaylistIds.length} playlists',
      );
    } catch (e) {
      log('❌ Error adding songs to playlists: $e');
      Get.snackbar('Error', 'Failed to add songs to playlists');
    }
  }

  /// Reorder songs in current playlist
  Future<void> reorderPlaylistSongs(int oldIndex, int newIndex) async {
    try {
      final playlistId = currentPlaylistId.value;
      if (playlistId.isEmpty) return;

      final success = await AppPlaylistService.reorderPlaylistSongs(
        playlistId: playlistId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );

      if (success) {
        await loadPlaylistSongs(playlistId);
      }
    } catch (e) {
      log('❌ Error reordering songs: $e');
    }
  }

  /// REVERT: Load favorite map from Hive (old style)
  Future<void> loadFavoritesFromHive() async {
    try {
      final favoriteMap = box.get("favorite");
      if (favoriteMap != null && favoriteMap is Map) {
        isfavorite = Map<dynamic, dynamic>.from(favoriteMap);
        log(
          '❤️ Loaded ${isfavorite.length} favorites from storage (old style)',
        );
      } else {
        isfavorite = {};
      }
    } catch (e) {
      log('❌ Error loading favorites map: $e');
      isfavorite = {};
    }
  }

  /// CHANGED: Make these methods async and reload favorites
  Future<void> addToFavorites(MediaItem song) async {
    isfavorite[song.id] = true;
    await box.put("favorite", isfavorite);
    await loadFavorites();
    update();
  }

  Future<void> removeFromFavorites(MediaItem song) async {
    isfavorite.remove(song.id);
    await box.put("favorite", isfavorite);
    await loadFavorites();
    update();
  }

  Future<RxList<MediaItem>> loadFavorites() async {
    try {
      List keys = isfavorite.keys.toList();
      List<MediaItem> tempFavorites = []; // Use temporary list
      log('🔍 Checking songscontroller.songs IDs:');
      for (var s in songscontroller.songs.take(3)) {
        log('  - ${s.id} - ${s.title}');
      }
      log('🔍 Loading favorites: ${isfavorite.length} keys found');
      log('🔍 Keys: $keys');

      for (var i = 0; i < isfavorite.length; i++) {
        try {
          // Find the song in songscontroller.songs
          MediaItem song = songscontroller.songs.firstWhere(
            (element) => element.id == keys[i],
          );
          tempFavorites.add(song);
          log('✅ Added favorite: ${song.title} (ID: ${keys[i]})');
        } catch (e) {
          log('❌ Could not find song with ID: ${keys[i]}');
        }
      }

      log('🎵 Favorites before sorting: ${tempFavorites.length}');

      // Sort favorites
      if (tempFavorites.isNotEmpty) {
        final sortedList = sort(
          song: tempFavorites,
          sortType: songscontroller.sortypeFavorite ?? "titleASC",
        );
        log('🎵 Sorted list length: ${sortedList.length}');
        favorites.assignAll(sortedList);
      } else {
        favorites.clear();
      }

      log('🎵 Total favorites loaded: ${favorites.length}');
      return favorites;
    } catch (e) {
      log('❌ Error loading favorites: $e');
      return <MediaItem>[].obs;
    }
  }

  // Update your toggleFavorite method:
  Future<void> toggleFavorite(MediaItem song) async {
    if (isfavorite.containsKey(song.id)) {
      removefavorite(song);
      Get.snackbar('Removed', 'Removed from favorites');
    } else {
      addfavorite(song);
      Get.snackbar('Added', 'Added to favorites');
    }
    favoriteUpdated.toggle(); // This triggers Obx updates
  }

  // Update addfavorite and removefavorite:
  void addfavorite(MediaItem song) {
    isfavorite[song.id] = true;
    box.put("favorite", isfavorite);
    log('❤️ Added to favorites: ${song.title} (ID: ${song.id})');
    loadFavorites();
    favoriteUpdated.toggle(); // Trigger update
  }

  void removefavorite(MediaItem song) {
    isfavorite.remove(song.id);
    box.put("favorite", isfavorite);
    log('💔 Removed from favorites: ${song.title} (ID: ${song.id})');
    loadFavorites();
    favoriteUpdated.toggle(); // Trigger update
  }

  /// REVERT: Use old method for handling favorites playback
  Future<void> handleFavorites() async {
    if (favorites.isEmpty) {
      Get.snackbar('Info', 'No favorite songs found');
      return;
    }

    await songHandler.initSongs(songs: favorites);
    animationController.reset();
    Get.snackbar('Playing', 'Favorites playlist loaded');
  }
// Add these to Playlistcontroller class:

/// Update song in favorites list
void updateSongInFavorites(String songId, MediaItem updatedSong) {
  final index = favorites.indexWhere((item) => item.id == songId);
  if (index != -1) {
    favorites[index] = updatedSong;
    log('✅ Updated song in favorites: ${updatedSong.title}');
    update();
  }
}

/// Update song in current playlist
void updateSongInCurrentPlaylist(String songId, MediaItem updatedSong) {
  final index = currentPlaylistSongs.indexWhere((item) => item.id == songId);
  if (index != -1) {
    currentPlaylistSongs[index] = updatedSong;
    log('✅ Updated song in current playlist: ${updatedSong.title}');
    update();
  }
}
  /// Helper method to check if a song is favorited
  RxBool isSongFavorited(String songId) {
    return isfavorite.containsKey(songId).obs;
  }
}
