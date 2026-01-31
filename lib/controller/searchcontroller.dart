import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/main.dart';

class Searchcontroller extends GetxController {
  final Songscontroller songsController = Get.find();
  final TextEditingController textController = TextEditingController();

  final RxList<MediaItem> filteredSongs = <MediaItem>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _isSearching = false.obs;
  final RxBool _hasError = false.obs;

  String get searchQuery => _searchQuery.value;
  bool get isSearching => _isSearching.value;
  bool get hasError => _hasError.value;
  bool get hasResults => filteredSongs.isNotEmpty;
  int get resultCount => filteredSongs.length;

  Timer? _debounceTimer;
  static const Duration debounceDelay = Duration(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    ever(songsController.songs, (_) => _reFilterIfNeeded());
  }

  void _reFilterIfNeeded() {
    if (_searchQuery.value.isNotEmpty) {
      performSearch(_searchQuery.value);
    }
  }

  void search(String query) {
    _debounceTimer?.cancel();

    _searchQuery.value = query.trim();

    if (query.isEmpty) {
      filteredSongs.clear();
      _isSearching.value = false;
      return;
    }

    _isSearching.value = true;
    _hasError.value = false;

    _debounceTimer = Timer(debounceDelay, () {
      performSearch(query);
    });
  }

  void performSearch(String query) {
    try {
      final searchTerm = query.toLowerCase();

      final results = songsController.songs.where((song) {
        return song.title.toLowerCase().contains(searchTerm) ||
            (song.artist?.toLowerCase().contains(searchTerm) ?? false) ||
            (song.album?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();

      filteredSongs.assignAll(results);
      _isSearching.value = false;
    } catch (e) {
      debugPrint('Search error: $e');
      filteredSongs.clear();
      _hasError.value = true;
      _isSearching.value = false;
    }
  }

  Future<void> playSongFromSearch(MediaItem song) async {
    try {
      // Find index in all songs
      final allSongs = songsController.songs;
      final songIndex = allSongs.indexWhere((s) => s.id == song.id);

      if (songIndex != -1) {
        // Play the song
        await songsController.handleAllSongs();
        await songHandler.skipToQueueItem(songIndex);
        songHandler.play();
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
    filteredSongs.clear();
    textController.clear();
    _isSearching.value = false;
    _hasError.value = false;
  }

  // Optional: Get search suggestions
  List<String> getSearchSuggestions(String query, {int limit = 5}) {
    if (query.isEmpty) return [];

    final searchTerm = query.toLowerCase();
    final suggestions = <String>{};

    for (final song in songsController.songs) {
      if (song.title.toLowerCase().contains(searchTerm)) {
        suggestions.add(song.title);
      }
      if (song.artist?.toLowerCase().contains(searchTerm) ?? false) {
        suggestions.add(song.artist!);
      }
      if (suggestions.length >= limit) break;
    }

    return suggestions.toList();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    textController.dispose();
    super.onClose();
  }
}
