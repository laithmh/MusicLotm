import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/core/model/playlist_model.dart';
import 'package:musiclotm/core/service/playlist_service.dart';

class Playlistcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  AnimationControllerX animationController = Get.find();
  SongHandler get songHandler => Get.find<SongHandler>();

  final TextEditingController playlistNameController = TextEditingController();
  final TextEditingController playlistDescriptionController =
      TextEditingController();

  late Box box;
  RxList<MediaItem> favorites = <MediaItem>[].obs;
  RxBool favoriteUpdated = false.obs;

  RxList<String> favoriteIds = <String>[].obs;
  // Observables
  RxList<AppPlaylist> playlists = <AppPlaylist>[].obs;
  RxList<MediaItem> currentPlaylistSongs = <MediaItem>[].obs;
  RxString currentPlaylistId = ''.obs;
  RxString currentPlaylistName = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isPlayingFromPlaylist = false.obs;

  // Sorting
  RxString sortTypePlaylists = "titleASC".obs;
  RxString sortTypeFavorites = "titleASC".obs;

  // Selection
  final RxList<String> selectedSongIds = <String>[].obs;
  final RxList<String> selectedPlaylistIds = <String>[].obs;
  RxBool isSelectionMode = false.obs;

  // Search
  RxString searchQuery = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await _initMusicBox();
    await _loadSavedState();
    await loadFavoritesFromHive(); // load the ordered list
    ever(songscontroller.songs, (_) {
      if (songscontroller.songs.isNotEmpty) {
        loadFavorites(); // rebuild UI when songs arrive
      }
    });
    await loadAppPlaylists();
    await _restoreCurrentPlaylist();
  }

  @override
  void onClose() {
    _saveCurrentState();
    playlistNameController.dispose();
    playlistDescriptionController.dispose();
    super.onClose();
  }

  // FIX: Safe box initialisation
  Future<void> _initMusicBox() async {
    try {
      if (!Hive.isBoxOpen('music')) {
        box = await Hive.openBox('music');
      } else {
        box = Hive.box('music');
      }
    } catch (e) {
      log('❌ Failed to open music box: $e');
      rethrow;
    }
  }

  /// Save current state to Hive
  Future<void> _saveCurrentState() async {
    try {
      // Save current playlist state
      if (currentPlaylistId.value.isNotEmpty) {
        box.put("currentPlaylistId", currentPlaylistId.value);
        box.put("currentPlaylistName", currentPlaylistName.value);
      } else {
        box.delete("currentPlaylistId");
        box.delete("currentPlaylistName");
      }

      // Save sort types
      box.put("sortTypePlaylists", sortTypePlaylists.value);
      box.put("sortTypeFavorites", sortTypeFavorites.value);

      // Save playing state
      box.put("isPlayingFromPlaylist", isPlayingFromPlaylist.value);

      log('✅ Playlist state saved: ${currentPlaylistId.value}');
    } catch (e) {
      log('❌ Error saving playlist state: $e');
    }
  }

  /// Load saved state from Hive
  Future<void> _loadSavedState() async {
    try {
      // Load sort types
      sortTypePlaylists.value = box.get(
        "sortTypePlaylists",
        defaultValue: "titleASC",
      );
      sortTypeFavorites.value = box.get(
        "sortTypeFavorites",
        defaultValue: "titleASC",
      );

      // Load playing state
      isPlayingFromPlaylist.value = box.get(
        "isPlayingFromPlaylist",
        defaultValue: false,
      );

      // Load current playlist info
      currentPlaylistId.value = box.get("currentPlaylistId", defaultValue: '');
      currentPlaylistName.value = box.get(
        "currentPlaylistName",
        defaultValue: '',
      );

      log('📋 Loaded playlist state: ${currentPlaylistId.value}');
    } catch (e) {
      log('❌ Error loading playlist state: $e');
    }
  }

  Future<void> _restoreCurrentPlaylist() async {
    try {
      if (currentPlaylistId.value.isEmpty) return;

      // ✅ Skip restoration if already playing this playlist
      if (isPlayingFromPlaylist.value &&
          songHandler.mediaItem.value != null &&
          currentPlaylistSongs.any(
            (s) => s.id == songHandler.mediaItem.value!.id,
          )) {
        log('⏭️ Already playing this playlist - skipping restoration');
        return;
      }

      final playlist = AppPlaylistService.getPlaylist(currentPlaylistId.value);
      if (playlist != null) {
        await loadPlaylistSongs(currentPlaylistId.value, restoreState: true);
        log('🎵 Restored playlist: ${playlist.name}');
      } else {
        // Playlist no longer exists, clear saved state
        currentPlaylistId.value = '';
        currentPlaylistName.value = '';
        await _saveCurrentState();
      }
    } catch (e) {
      log('❌ Error restoring playlist: $e');
    }
  }

  /// Load favorite map from Hive
  Future<void> loadFavoritesFromHive() async {
    try {
      final dynamic data = box.get("favorite");
      if (data != null) {
        if (data is List) {
          favoriteIds.value = List<String>.from(data);
        } else if (data is Map) {
          // Convert old map to list (keys only)
          favoriteIds.value = data.keys.cast<String>().toList();
        }
      } else {
        favoriteIds.clear();
      }
      log('❤️ Loaded ${favoriteIds.length} favorite IDs');
    } catch (e) {
      log('❌ Error loading favorites: $e');
      favoriteIds.clear();
    }
  }

  /// Load app-specific playlists
  Future<void> loadAppPlaylists() async {
    try {
      isLoading.value = true;
      final loadedPlaylists = AppPlaylistService.getAllPlaylists();
      playlists.assignAll(loadedPlaylists);
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

      // Auto-select the new playlist
      await loadPlaylistSongs(playlist.id, restoreState: false);

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
        currentPlaylistName.value = '';
        currentPlaylistSongs.clear();
        isPlayingFromPlaylist.value = false;

        // Save cleared state
        await _saveCurrentState();
      }

      Get.snackbar('Success', 'Playlist deleted');
    } catch (e) {
      log('❌ Error deleting playlist: $e');
      Get.snackbar('Error', 'Failed to delete playlist');
    }
  }

  /// Load playlist songs with performance optimization and reload guarding
  Future<void> loadPlaylistSongs(
    String playlistId, {
    bool restoreState = false,
    bool force = false,
  }) async {
    // Prevent reloading the same playlist unless forced
    if (!force &&
        playlistId == currentPlaylistId.value &&
        currentPlaylistSongs.isNotEmpty) {
      log('⏭️ Already loaded playlist $playlistId, skipping');

      return;
    }
    try {
      isLoading.value = true;
      currentPlaylistId.value = playlistId;

      final playlist = AppPlaylistService.getPlaylist(playlistId);
      if (playlist == null) {
        currentPlaylistSongs.clear();
        currentPlaylistName.value = '';
        return;
      }

      currentPlaylistName.value = playlist.name;

      final Map<String, MediaItem> allSongsMap = {
        for (var song in songscontroller.songs) song.id: song,
      };

      final List<MediaItem> sortedSongs = playlist.songIds.map((id) {
        return allSongsMap[id] ??
            MediaItem(id: id, title: 'Unknown Song', artist: 'Unknown Artist');
      }).toList();

      currentPlaylistSongs.assignAll(sortedSongs);
      await _saveCurrentState();

      log('🎵 Loaded ${sortedSongs.length} songs for: ${playlist.name}');

      if (restoreState && isPlayingFromPlaylist.value) {
        await _restorePlaylistPlayback();
        log('🎵 Restored playback for playlist: ${playlist.name}');
      }
    } catch (e) {
      log('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Optimized: Check if playlist is already active before re-initializing audio handler
  Future<void> handlePlaylist(
    String playlistId, {
    bool restoreState = false,
    int? initialIndex,
  }) async {
    try {
      bool alreadyPlayingThis =
          isPlayingFromPlaylist.value && currentPlaylistId.value == playlistId;

      await loadPlaylistSongs(
        playlistId,
        restoreState: restoreState,
        force: false,
      );

      if (currentPlaylistSongs.isNotEmpty) {
        final currentQueue = songHandler.queue.value;
        bool isSameQueue =
            currentQueue.length == currentPlaylistSongs.length &&
            currentQueue.asMap().entries.every(
              (entry) => entry.value.id == currentPlaylistSongs[entry.key].id,
            );

        if (isSameQueue && alreadyPlayingThis && !restoreState) {
          // Queue already matches – just skip to the requested index
          if (initialIndex != null) {
            await songHandler.skipToQueueItem(initialIndex);
            await songHandler.play();
          }
        } else {
          // Queue differs – initialise the player with the playlist
          isPlayingFromPlaylist.value = true;
          await _saveCurrentState();
          await songHandler.initSongs(
            songs: currentPlaylistSongs,
            restoreState: restoreState,
            initialIndex: initialIndex ?? 0,
          );
          animationController.reset();
        }
      }
    } catch (e) {
      log('❌ Error: $e');
    }
  }

  /// Restore playlist playback from saved state
  Future<void> _restorePlaylistPlayback() async {
    try {
      if (currentPlaylistSongs.isNotEmpty) {
        await songHandler.initSongs(
          songs: currentPlaylistSongs,
          restoreState: true,
        );
        log('🎵 Restored playlist playback');
      }
    } catch (e) {
      log('❌ Error restoring playlist playback: $e');
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
        if (currentPlaylistId.value == playlistId) {
          final song = songscontroller.songs.firstWhereOrNull(
            (s) => s.id == songId,
          );
          if (song != null &&
              !currentPlaylistSongs.any((s) => s.id == songId)) {
            currentPlaylistSongs.add(song);
            await _saveCurrentState();
          }
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
          // Save updated state
          await _saveCurrentState();
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
          // Save cleared state
          await _saveCurrentState();
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

      // Update current playlist name if it's the current one
      if (currentPlaylistId.value == playlistId) {
        currentPlaylistName.value = newName;
        await _saveCurrentState();
      }

      Get.snackbar('Success', 'Playlist renamed to "$newName"');
    } catch (e) {
      log('❌ Error renaming playlist: $e');
      Get.snackbar('Error', 'Failed to rename playlist');
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

  void updatePlaylistSortType(String type) {
    sortTypePlaylists.value = type;
    box.put("sortTypePlaylists", type);

    // If a playlist is currently open, reorder it permanently
    if (currentPlaylistId.value.isNotEmpty) {
      _reorderCurrentPlaylistBySortType();
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

  /// Adds a specific song to all currently selected playlists
  /// Handles duplicate checking and UI feedback
  Future<void> addSongToSelectedPlaylists(String songId) async {
    if (selectedPlaylistIds.isEmpty) {
      Get.snackbar('Info', 'Please select at least one playlist');
      return;
    }

    int addedCount = 0;
    int duplicateCount = 0;

    try {
      for (final playlistId in selectedPlaylistIds) {
        // 1. Check for duplicates to avoid unnecessary DB writes
        final playlist = playlists.firstWhereOrNull((p) => p.id == playlistId);
        
        if (playlist != null && playlist.songIds.contains(songId)) {
          duplicateCount++;
          continue; // Skip this playlist if song already exists
        }

        // 2. Add to local storage via service
        final success = await AppPlaylistService.addSongToPlaylist(
          playlistId: playlistId,
          songId: songId,
        );

        if (success) {
          addedCount++;
          
          // 3. Update current UI state if the user is currently viewing this playlist
          if (currentPlaylistId.value == playlistId) {
            final song = songscontroller.songs.firstWhereOrNull((s) => s.id == songId);
            if (song != null && !currentPlaylistSongs.any((s) => s.id == songId)) {
              currentPlaylistSongs.add(song);
              await _saveCurrentState();
            }
          }
        }
      }

      // 4. Handle UI navigation and clean up
      clearSelections();

      // 5. Dynamic SnackBar feedback based on the result
      if (addedCount > 0) {
        String msg = 'Added to $addedCount playlist${addedCount > 1 ? 's' : ''}';
        if (duplicateCount > 0) {
          msg += ' ($duplicateCount already existed)';
        }
        Get.snackbar('Success', msg);
      } else if (duplicateCount > 0) {
        Get.snackbar('Info', 'Song already exists in the selected playlist(s)');
      }

    } catch (e) {
      log('❌ Error adding song to multiple playlists: $e');
      Get.snackbar('Error', 'Failed to add song to playlists');
    }
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

  /// Delete selected songs from device
  Future<void> deleteSelectedSongs() async {
    if (selectedSongIds.isEmpty) {
      Get.snackbar('Info', 'Please select songs to delete');
      return;
    }

    try {
      // Confirm deletion
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: ThemeData().colorScheme.surface,
          title: const Text('Delete Songs'),
          content: Text(
            'Are you sure you want to delete ${selectedSongIds.length} song(s)? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final mediaStore = MediaStore();
      int deletedCount = 0;

      for (final songId in selectedSongIds) {
        try {
          await mediaStore.deleteFileUsingUri(uriString: songId);
          log('✅ Deleted song: $songId');
          deletedCount++;
        } catch (e) {
          log('❌ Failed to delete song $songId: $e');
        }
      }

      // Clear selections and exit selection mode
      clearSelections();
      isSelectionMode.value = false;

      // Reload songs to reflect deletions
      await songscontroller.loadSongs();

      Get.snackbar(
        'Success',
        'Successfully deleted $deletedCount song(s)',
      );
    } catch (e) {
      log('❌ Error deleting songs: $e');
      Get.snackbar('Error', 'Failed to delete songs');
    }
  }

  Future<void> _reorderCurrentPlaylistBySortType() async {
    final playlistId = currentPlaylistId.value;
    if (playlistId.isEmpty) return;

    final playlist = AppPlaylistService.getPlaylist(playlistId);
    if (playlist == null) return;

    // Build a map of all songs for O(1) lookup
    final Map<String, MediaItem> allSongsMap = {
      for (var song in songscontroller.songs) song.id: song,
    };

    // Get the actual MediaItem objects in the current playlist order
    List<MediaItem> songs = playlist.songIds
        .map((id) => allSongsMap[id])
        .whereType<MediaItem>()
        .toList();

    if (songs.isEmpty) return; // nothing to sort

    // Sort the songs using the utility function
    final sortedSongs = sort(song: songs, sortType: sortTypePlaylists.value);

    // Extract the new ordered list of IDs
    final newSongIds = sortedSongs.map((s) => s.id).toList();

    // Update the playlist object
    playlist.songIds.clear();
    playlist.songIds.addAll(newSongIds);

    // Save to storage
    await AppPlaylistService.updatePlaylist(playlist);

    // Reload the UI with the new order (force refresh)
    await loadPlaylistSongs(playlistId, force: true);
  }

  /// Reorder songs in current playlist
  Future<void> reorderPlaylistSongs(int oldIndex, int newIndex) async {
    try {
      final playlistId = currentPlaylistId.value;
      if (playlistId.isEmpty) {
        log('❌ No current playlist ID');
        Get.snackbar('Error', 'No playlist selected');
        return;
      }

      if (oldIndex < 0 || oldIndex >= currentPlaylistSongs.length) {
        log('❌ Invalid oldIndex: $oldIndex');
        Get.snackbar('Error', 'Invalid starting position');
        return;
      }
      if (newIndex < 0 || newIndex >= currentPlaylistSongs.length) {
        log('❌ Invalid newIndex: $newIndex');
        Get.snackbar('Error', 'Invalid target position');
        return;
      }
      if (oldIndex == newIndex) return;

      final movedItem = currentPlaylistSongs[oldIndex];

      // Optimistic UI update
      currentPlaylistSongs.removeAt(oldIndex);
      currentPlaylistSongs.insert(newIndex, movedItem);
      currentPlaylistSongs.refresh();
      update();

      // Persist the change using the fixed service method
      final success = await AppPlaylistService.reorderPlaylistSongs(
        playlistId: playlistId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );

      if (!success) {
        // Rollback
        currentPlaylistSongs.removeAt(newIndex);
        currentPlaylistSongs.insert(oldIndex, movedItem);
        currentPlaylistSongs.refresh();
        update();
        Get.snackbar('Error', 'Failed to save changes to storage');
      } else {
        log('✅ Reorder saved successfully!');
        Get.snackbar(
          'Success',
          'Playlist order updated',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      log('❌ Exception in reorderPlaylistSongs: $e');
      Get.snackbar(
        'Error',
        'Failed to reorder: ${e.toString().split('\n').first}',
      );
    }
  }

  Future<void> addToFavorites(MediaItem song) async {
    if (!favoriteIds.contains(song.id)) {
      favoriteIds.add(song.id);
      await box.put("favorite", favoriteIds.toList());
      await loadFavorites();
      update();
    }
  }

  Future<void> removeFromFavorites(MediaItem song) async {
    if (favoriteIds.contains(song.id)) {
      favoriteIds.remove(song.id);
      await box.put("favorite", favoriteIds.toList());
      await loadFavorites();
      update();
    }
  }

  void toggleFavorite(MediaItem song) {
    if (favoriteIds.contains(song.id)) {
      removeFromFavorites(song);
      Get.snackbar('Removed', 'Removed from favorites');
    } else {
      addToFavorites(song);
      Get.snackbar('Added', 'Added to favorites');
    }
  }

  bool isSongFavorited(String songId) => favoriteIds.contains(songId);

  /// Optimized: Load favorites using Map-based lookup for performance
  Future<RxList<MediaItem>> loadFavorites() async {
    try {
      if (favoriteIds.isEmpty || songscontroller.songs.isEmpty) {
        favorites.clear();
        return favorites;
      }

      final Map<String, MediaItem> allSongsMap = {
        for (var song in songscontroller.songs) song.id: song,
      };

      final List<MediaItem> temp = [];
      for (var id in favoriteIds) {
        final song = allSongsMap[id];
        if (song != null) temp.add(song);
      }

      favorites.assignAll(temp);
      log('❤️ Displayed ${favorites.length} favorites');
      return favorites;
    } catch (e) {
      log('❌ Error loading favorites: $e');
      return favorites;
    }
  }

  Future<void> reorderFavorites(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= favoriteIds.length) return;
    if (newIndex < 0 || newIndex >= favoriteIds.length) return;
    if (oldIndex == newIndex) return;

    final movedId = favoriteIds.removeAt(oldIndex);
    favoriteIds.insert(newIndex, movedId);

    await box.put("favorite", favoriteIds.toList());
    await loadFavorites(); // updates UI
    update();
  }

  void updateFavoriteSortType(String type) {
    sortTypeFavorites.value = type;
    box.put("sortTypeFavorites", type);
    if (favoriteIds.isNotEmpty) {
      _sortFavoriteIds();
    }
  }

  Future<void> _sortFavoriteIds() async {
    // Map IDs to MediaItem objects
    final Map<String, MediaItem> allSongsMap = {
      for (var song in songscontroller.songs) song.id: song,
    };

    final List<MediaItem> songs = favoriteIds
        .map((id) => allSongsMap[id])
        .whereType<MediaItem>()
        .toList();

    if (songs.isEmpty) return;

    // Sort using the existing utility
    final sorted = sort(song: songs, sortType: sortTypeFavorites.value);

    // Extract new ordered IDs
    final newIds = sorted.map((s) => s.id).toList();

    favoriteIds.value = newIds;
    await box.put("favorite", favoriteIds.toList());
    await loadFavorites();
    update();
  }

  Future<void> handleFavorites({
    bool restoreState = false,
    bool showSnackbar = true,
    int? initialIndex,
  }) async {
    if (favorites.isEmpty) {
      if (showSnackbar) Get.snackbar('Info', 'No favorite songs found');
      return;
    }

    // Check if the current queue is already the favorites list (same order)
    final currentQueue = songHandler.queue.value;
    bool isSameQueue =
        currentQueue.length == favorites.length &&
        currentQueue.asMap().entries.every(
          (entry) => entry.value.id == favorites[entry.key].id,
        );

    if (isSameQueue && !restoreState) {
      // Queue already matches – just skip to the requested index
      if (initialIndex != null) {
        await songHandler.skipToQueueItem(initialIndex);
        await songHandler.play();
      }
    } else {
      // Queue differs – initialise the player with the favorites list
      isPlayingFromPlaylist.value = false;
      await _saveCurrentState();
      await songHandler.initSongs(
        songs: favorites,
        restoreState: restoreState,
        initialIndex: initialIndex ?? 0,
      );
      animationController.reset();
    }

    // Only show snackbar if we actually loaded a new queue
    if (showSnackbar && !isSameQueue) {
      Get.snackbar('Playing', 'Favorites playlist loaded');
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

  /// Get current playlist state for debugging
  Map<String, dynamic> getCurrentPlaylistState() {
    return {
      'currentPlaylistId': currentPlaylistId.value,
      'currentPlaylistName': currentPlaylistName.value,
      'playlistSongCount': currentPlaylistSongs.length,
      'isPlayingFromPlaylist': isPlayingFromPlaylist.value,
      'favoriteCount': favorites.length,
      'sortTypePlaylists': sortTypePlaylists.value,
      'sortTypeFavorites': sortTypeFavorites.value,
    };
  }

  /// Clear all saved playlist states
  Future<void> clearAllSavedStates() async {
    try {
      // Clear saved playlist state
      box.delete("currentPlaylistId");
      box.delete("currentPlaylistName");
      box.delete("sortTypePlaylists");
      box.delete("sortTypeFavorites");
      box.delete("isPlayingFromPlaylist");

      // Reset current state
      currentPlaylistId.value = '';
      currentPlaylistName.value = '';
      currentPlaylistSongs.clear();
      isPlayingFromPlaylist.value = false;

      log('✅ Cleared all playlist states');
    } catch (e) {
      log('❌ Error clearing playlist states: $e');
    }
  }

  /// Check if current song is from playlist
  bool isCurrentSongFromPlaylist() {
    final currentSong = songHandler.mediaItem.value;
    if (currentSong == null) return false;

    return currentPlaylistSongs.any((song) => song.id == currentSong.id);
  }

  /// Navigate to next/previous song within playlist
  Future<void> navigateInPlaylist(bool next) async {
    if (!isCurrentSongFromPlaylist()) return;

    final currentSong = songHandler.mediaItem.value;
    if (currentSong == null) return;

    final currentIndex = currentPlaylistSongs.indexWhere(
      (song) => song.id == currentSong.id,
    );
    if (currentIndex == -1) return;

    int newIndex;
    if (next) {
      newIndex = (currentIndex + 1) % currentPlaylistSongs.length;
    } else {
      newIndex = currentIndex > 0
          ? currentIndex - 1
          : currentPlaylistSongs.length - 1;
    }

    await songHandler.skipToQueueItem(newIndex);
  }
}