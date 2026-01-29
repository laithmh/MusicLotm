import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/songscontroller.dart';

class Searchcontroller extends GetxController {
  late final Songscontroller songscontroller;
  final TextEditingController controller = TextEditingController();
  
  final RxList<MediaItem> filteredData = <MediaItem>[].obs;
  final RxString _searchQuery = ''.obs;
  
  String get searchQuery => _searchQuery.value;
  
  @override
  void onInit() {
    super.onInit();
    songscontroller = Get.find<Songscontroller>(); // Use find instead of put
    
    // Listen for changes in the main songs list and re-filter if needed
    ever(songscontroller.songs, (_) => _reFilterIfNeeded());
  }

  void _reFilterIfNeeded() {
    if (_searchQuery.value.isNotEmpty) {
      _performSearch(_searchQuery.value);
    }
  }

  void filterData(String songName) {
    _searchQuery.value = songName;
    
    if (songName.trim().isEmpty) {
      filteredData.clear();
      return;
    }
    
    _performSearch(songName.toLowerCase());
  }

  void _performSearch(String searchTerm) {
    try {
      final results = songscontroller.songs
          .where((item) => item.title.toLowerCase().contains(searchTerm))
          .toList();
      
      filteredData.assignAll(results);
    } catch (e) {
      debugPrint('Error filtering search data: $e');
      filteredData.clear();
    }
  }

  // Debounced search for better performance
  Timer? _debounceTimer;
  
  void debouncedFilterData(String songName, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(delay, () {
      filterData(songName);
    });
  }

  // Clear search results
  void clearSearch() {
    _searchQuery.value = '';
    filteredData.clear();
    controller.clear();
  }

  // Get search results count
  int get searchResultCount => filteredData.length;

  // Check if search has results
  bool get hasResults => filteredData.isNotEmpty;

  // Check if search is active
  bool get isSearching => _searchQuery.value.isNotEmpty;

  // Perform advanced search with multiple criteria
  void advancedFilter({
    String? title,
    String? artist,
    String? album,
  }) {
    final searchTerm = (title ?? '').toLowerCase();
    final artistTerm = (artist ?? '').toLowerCase();
    final albumTerm = (album ?? '').toLowerCase();

    final results = songscontroller.songs.where((item) {
      bool matchesTitle = title == null || 
          item.title.toLowerCase().contains(searchTerm);
      bool matchesArtist = artist == null || 
          (item.artist?.toLowerCase().contains(artistTerm) ?? false);
      bool matchesAlbum = album == null || 
          (item.album?.toLowerCase().contains(albumTerm) ?? false);

      return matchesTitle || matchesArtist || matchesAlbum;
    }).toList();

    filteredData.assignAll(results);
  }

  // Search with case sensitivity option
  void caseSensitiveFilter(String songName, {bool caseSensitive = false}) {
    _searchQuery.value = songName;
    
    if (songName.trim().isEmpty) {
      filteredData.clear();
      return;
    }

    try {
      final results = songscontroller.songs.where((item) {
        if (caseSensitive) {
          return item.title.contains(songName);
        } else {
          return item.title.toLowerCase().contains(songName.toLowerCase());
        }
      }).toList();
      
      filteredData.assignAll(results);
    } catch (e) {
      debugPrint('Error in case-sensitive search: $e');
      filteredData.clear();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    controller.dispose(); // Dispose controller instead of just clearing
    super.onClose();
  }
}