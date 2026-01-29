import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/core/function/song_to_media_item.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Playlistcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  AnimationControllerX animationController = Get.find();
  
  final StreamController<RxList<MediaItem>> _streamController =
      StreamController<RxList<MediaItem>>.broadcast();

  Stream<RxList<MediaItem>> get myplaylistStream => _streamController.stream;

  final TextEditingController controller = TextEditingController();

  final OnAudioQuery audioQuery = OnAudioQuery();
  RxList<MediaItem> mediasongs = <MediaItem>[].obs;
  RxList<MediaItem> favorites = <MediaItem>[].obs;

  Map<String, bool> isfavorite = {};
  late List<PlaylistModel> playlists = [];

  late int playlistindex = 0;
  final List<int> _selectedPlaylistIds = [];
  final List<String> _selectedSongTitles = [];

  bool selectionMode = false;
  late int playlistId = 0;
  late int newplaylistID = 0;

  // Computed properties for better performance
  List<int> get selectedPlaylistIds => List.unmodifiable(_selectedPlaylistIds);
  List<String> get selectedSongTitles => List.unmodifiable(_selectedSongTitles);

  Future<void> handlePlaylists() async {
    if (mediasongs.isEmpty) return;
    
    newplaylistID = playlistId;
    await songHandler.initSongs(songs: mediasongs);
    animationController.reset();
  }

  void onPlaylistSelected(bool? selected, int playlistId) {
    if (selected == true) {
      if (!_selectedPlaylistIds.contains(playlistId)) {
        _selectedPlaylistIds.add(playlistId);
      }
    } else {
      _selectedPlaylistIds.remove(playlistId);
    }
    log("Selected playlist IDs: $_selectedPlaylistIds");
    update();
  }

  void onSongSelected(bool? selected, String songTitle) {
    if (selected == true) {
      if (!_selectedSongTitles.contains(songTitle)) {
        _selectedSongTitles.add(songTitle);
      }
    } else {
      _selectedSongTitles.remove(songTitle);
    }
    log("Selected song titles: $_selectedSongTitles");
    update();
  }

  void toggleSelection() {
    selectionMode = !selectionMode;
    update();
    animationController.update();
  }

  Future<void> createNewPlaylist() async {
    final String playlistName = controller.text.trim();
    if (playlistName.isEmpty) {
      Get.snackbar("Error", "Playlist name cannot be empty");
      return;
    }

    try {
      final bool playlistCreated = await audioQuery.createPlaylist(playlistName);
      playlists = await audioQuery.queryPlaylists();

      if (playlistCreated) {
        log('Playlist created successfully!');
        Get.snackbar("Success", "Playlist '$playlistName' created successfully!");
      } else {
        log('Failed to create the playlist.');
        Get.snackbar("Error", "Failed to create the playlist.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create playlist: $e");
    }
    update();
  }

  Future<void> addSongsToPlaylist(MediaItem mediaSong) async {
    if (_selectedPlaylistIds.isEmpty) {
      Get.snackbar("Info", "Please select at least one playlist first");
      return;
    }

    try {
      playlists = await audioQuery.queryPlaylists();
      
      for (int playlistId in _selectedPlaylistIds) {
        List<SongModel> playlistSongs = await audioQuery.queryAudiosFrom(
          AudiosFromType.PLAYLIST, 
          playlistId
        );
        
        bool songExists = playlistSongs.any(
          (element) => element.displayNameWOExt == mediaSong.title
        );
        
        if (songExists) {
          Get.snackbar(
            "Already Exists", 
            "Song '${mediaSong.title}' already exists in playlist ID $playlistId."
          );
          continue;
        }

        SongModel? song = songscontroller.songModels.firstWhere(
          (element) => element.displayNameWOExt == mediaSong.title,
          orElse: () => throw Exception("Song not found")
        );
        
        final bool added = await audioQuery.addToPlaylist(playlistId, song.id);
        
        if (added) {
          Get.snackbar(
            "Success", 
            "Song '${mediaSong.title}' added to playlist ID $playlistId successfully!"
          );
        } else {
          Get.snackbar(
            "Failed", 
            "Failed to add song '${mediaSong.title}' to playlist ID $playlistId."
          );
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Error adding song to playlist: $e");
    }
    update();
  }

  Future<void> addSongsToSelectedPlaylists() async {
    if (_selectedPlaylistIds.isEmpty || _selectedSongTitles.isEmpty) {
      Get.snackbar("Info", "Please select playlists and songs first");
      return;
    }

    try {
      for (int playlistId in _selectedPlaylistIds) {
        for (String songTitle in _selectedSongTitles) {
          List<SongModel> playlistSongs = await audioQuery.queryAudiosFrom(
            AudiosFromType.PLAYLIST, 
            playlistId
          );
          
          bool songExists = playlistSongs.any(
            (song) => song.displayNameWOExt == songTitle
          );
          
          if (songExists) {
            Get.snackbar(
              "Already Exists",
              "Song '$songTitle' already exists in playlist ID $playlistId."
            );
            continue;
          }

          SongModel? song = songscontroller.songModels.firstWhere(
            (element) => element.displayNameWOExt == songTitle,
            orElse: () => throw Exception("Song not found")
          );

          bool result = await audioQuery.addToPlaylist(playlistId, song.id);
          
          if (result) {
            Get.snackbar(
              "Success", 
              "Song '$songTitle' added to playlist ID $playlistId successfully!"
            );
          } else {
            Get.snackbar(
              "Failed", 
              "Failed to add song '$songTitle' to playlist ID $playlistId."
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Error adding songs to playlists: $e");
    }
  }

  Future<RxList<MediaItem>> loadSongsPlaylist(int playlistId) async {
    try {
      List<SongModel> playlistSongs = await audioQuery.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        playlistId,
        sortType: audioQuerySongSortType(songscontroller.sortypePlaylists ?? "titleASC"),
        orderType: audioQueryOrderType(songscontroller.sortypePlaylists ?? "titleASC"),
      );

      // Process songs in batches to prevent UI blocking
      const batchSize = 10;
      List<MediaItem> result = [];
      
      for (int i = 0; i < playlistSongs.length; i += batchSize) {
        final end = (i + batchSize).clamp(0, playlistSongs.length);
        final batch = playlistSongs.sublist(i, end);
        
        final batchResults = await Future.wait(
          batch.map((song) => songToMediaItem(
            getsongsartwork(song, songscontroller.songModels)
          ))
        );
        
        result.addAll(batchResults);
        await Future.delayed(Duration.zero); // Yield to UI
      }

      // Sort the results
      result = sort(
        song: result, 
        sortType: songscontroller.sortypePlaylists ?? "titleASC"
      );
      
      mediasongs.assignAll(result);
      return mediasongs;
    } catch (e) {
      debugPrint('Error fetching playlist songs: $e');
      mediasongs.clear();
      return mediasongs;
    }
  }

  Future<void> loadPlaylists() async {
    try {
      playlists = await audioQuery.queryPlaylists();
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      playlists = [];
    }
  }

  Future<void> deletePlaylist(int index, int playlistId) async {
    if (index >= playlists.length) {
      Get.snackbar("Error", "Invalid playlist index");
      return;
    }

    try {
      playlists.removeAt(index);
      await audioQuery.removePlaylist(playlistId);
      update();
      Get.snackbar("Success", "Playlist deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete playlist");
    }
  }

  Future<void> removeSongFromPlaylist(int playlistId, MediaItem mediaSong) async {
    try {
      SongModel? song = songscontroller.songModels.firstWhere(
        (element) => element.displayNameWOExt == mediaSong.title,
        orElse: () => throw Exception("Song not found")
      );
      
      bool done = await audioQuery.removeFromPlaylist(playlistId, song.id);
      
      if (done) {
        mediasongs.removeWhere((element) => element.title == song.displayNameWOExt);
        log("Song removed from playlist");
        Get.snackbar("Success", "Song removed from playlist");
      } else {
        Get.snackbar("Error", "Failed to remove song from playlist");
      }
    } catch (e) {
      Get.snackbar("Error", "Error removing song from playlist: $e");
    }
    update();
  }

  void addToFavorites(MediaItem song) {
    isfavorite[song.id] = true;
    box.put("favorite", isfavorite);
    update();
  }

  void removeFromFavorites(MediaItem song) {
    isfavorite.remove(song.id);
    box.put("favorite", isfavorite);
    update();
  }

  void toggleFavorite(MediaItem song) {
    if (isfavorite.containsKey(song.id)) {
      removeFromFavorites(song);
    } else {
      addToFavorites(song);
    }
  }

  Future<RxList<MediaItem>> loadFavorites() async {
    try {
      final keys = isfavorite.keys.toList();
      favorites.clear();
      
      // Filter songs that exist in the main library
      for (var key in keys) {
        final song = songscontroller.songs.firstWhere(
          (element) => element.id == key,
          orElse: () => MediaItem(
            id: "",
            album: "Unknown",
            title: "Unknown",
            artist: "Unknown",
          )
        );
        
        if (song.id.isNotEmpty) { // Only add valid songs
          favorites.add(song);
        }
      }

      final sortedFavorites = sort(
        song: favorites, 
        sortType: songscontroller.sortypeFavorite ?? "titleASC"
      );
      
      favorites.assignAll(sortedFavorites);
      return favorites;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      return favorites;
    }
  }

  Future<void> handleFavorites() async {
    if (favorites.isEmpty) return;
    
    await songHandler.initSongs(songs: favorites);
    animationController.reset();
  }

  // Clear selection methods
  void clearPlaylistSelection() {
    _selectedPlaylistIds.clear();
    update();
  }

  void clearSongSelection() {
    _selectedSongTitles.clear();
    update();
  }

  void clearAllSelections() {
    _selectedPlaylistIds.clear();
    _selectedSongTitles.clear();
    update();
  }

  @override
  void onClose() {
    _streamController.close();
    controller.dispose();
    super.onClose();
  }

  @override
  void onInit() async {
    // await songscontroller.requestSongPermission();
    playlistId = await box.get("playlistid", defaultValue: 0) ?? 0;
    
    await loadSongsPlaylist(playlistId);
    isfavorite = await box.get("favorite", defaultValue: <String, bool>{}) ?? {};
    await loadPlaylists();
    await loadFavorites();

    // Initialize based on current view state
    if (songscontroller.isallmusic.isTrue) {
      await songHandler.initSongs(songs: songscontroller.songs);
    } else if (songscontroller.isplaylist.isTrue) {
      await handlePlaylists();
    } else if (songscontroller.isfavorite.isTrue) {
      await handleFavorites();
    }
    
    // Resume playback position if available
    await songHandler.skipToQueueItem(songscontroller.currentSongPlayingIndex.value);
    await songHandler.seek(Duration(seconds: songscontroller.position));

    super.onInit();
  }
}