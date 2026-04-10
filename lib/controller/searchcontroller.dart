import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';

class Searchcontroller extends GetxController {
  final Songscontroller songsController = Get.find();
  SongHandler get songHandler => Get.find<SongHandler>();
  final TextEditingController textController = TextEditingController();

  final RxList<MediaItem> filteredSongs = <MediaItem>[].obs;
  final RxString _searchQuery = ''.obs;
  
  // Expose observables directly for simpler UI binding
  final RxBool isSearching = false.obs;
  final RxBool hasError = false.obs;

  String get searchQuery => _searchQuery.value;
  bool get hasResults => filteredSongs.isNotEmpty;
  int get resultCount => filteredSongs.length;

  @override
  void onInit() {
    super.onInit();
    
    // 1. Native GetX Debounce: Automatically waits 300ms after the user stops typing
    debounce(
      _searchQuery,
      performSearch,
      time: const Duration(milliseconds: 300),
    );
    
    // 2. Re-filter if the main song list changes while searching
    ever(songsController.songs, (_) => _reFilterIfNeeded());
  }

  void _reFilterIfNeeded() {
    if (_searchQuery.value.isNotEmpty) {
      performSearch(_searchQuery.value);
    }
  }

  void search(String query) {
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      clear();
      return;
    }

    isSearching.value = true;
    hasError.value = false;
    _searchQuery.value = trimmedQuery; // This automatically triggers the debounce
  }

  void performSearch(String query) {
    if (query.isEmpty) return;

    try {
      final searchTerm = query.toLowerCase();

      // 3. Optimized filtering with short-circuit evaluation
      final results = songsController.songs.where((song) {
        // If title matches, skip checking artist and album (faster processing)
        if (song.title.toLowerCase().contains(searchTerm)) return true;
        
        if (song.artist != null && song.artist!.toLowerCase().contains(searchTerm)) return true;
        
        if (song.album != null && song.album!.toLowerCase().contains(searchTerm)) return true;

        return false;
      }).toList();

      filteredSongs.assignAll(results);
    } catch (e) {
      debugPrint('Search error: $e');
      filteredSongs.clear();
      hasError.value = true;
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> playSongFromSearch(MediaItem song) async {
    try {
      final allSongs = songsController.songs;
      final songIndex = allSongs.indexWhere((s) => s.id == song.id);

      if (songIndex != -1) {
        await songsController.handleAllSongs();
        await songHandler.skipToQueueItem(songIndex);
        await songHandler.play();
      }
    } catch (e) {
      debugPrint('Error playing song from search: $e');
      Get.snackbar(
        'Error',
        'Could not play song',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clear() {
    _searchQuery.value = '';
    textController.clear();
    filteredSongs.clear();
    isSearching.value = false;
    hasError.value = false;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}