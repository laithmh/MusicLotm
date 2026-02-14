import 'dart:async';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:musiclotm/core/model/playlist_model.dart';
import 'package:uuid/uuid.dart';

class AppPlaylistService {
  static const String _boxName = 'appPlaylists';
  static late Box<AppPlaylist> _playlistBox;
  static late Box<Map<dynamic, dynamic>> _settingsBox;

  static bool _isInitialized = false;

  /// Initialize Hive and open boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive with a valid directory

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AppPlaylistAdapter());
      }

      // Open boxes
      _playlistBox = await Hive.openBox<AppPlaylist>(_boxName);
      _settingsBox = await Hive.openBox('playlistSettings');

      _isInitialized = true;
      log('✅ AppPlaylistService initialized successfully');

      // // Create a default playlist if none exist
      // await _createDefaultPlaylists();
    } catch (e) {
      log('❌ Error initializing AppPlaylistService: $e');
      rethrow;
    }
  }

  // /// Create default playlists
  // static Future<void> _createDefaultPlaylists() async {
  //   if (_playlistBox.isEmpty) {
  //     final defaultPlaylists = [

  //       AppPlaylist(
  //         name: 'Recently Added',
  //         description: 'Recently added songs',
  //       ),
  //       AppPlaylist(
  //         name: 'Most Played',
  //         description: 'Your most played tracks',
  //       ),
  //     ];

  //     for (final playlist in defaultPlaylists) {
  //       await _playlistBox.put(playlist.id, playlist);
  //     }
  //     log('📁 Created ${defaultPlaylists.length} default playlists');
  //   }
  // }

  /// CRUD Operations

  /// Create a new playlist
  static Future<AppPlaylist> createPlaylist({
    required String name,
    String? description,
    List<String>? initialSongs,
  }) async {
    _ensureInitialized();

    final playlist = AppPlaylist(
      name: name.trim(),
      description: description?.trim(),
      songIds: initialSongs,
    );

    await _playlistBox.put(playlist.id, playlist);
    log('➕ Created playlist: $name (ID: ${playlist.id})');
    return playlist;
  }

  /// Get all playlists
  static List<AppPlaylist> getAllPlaylists({bool sortByDate = true}) {
    _ensureInitialized();

    final playlists = _playlistBox.values.toList();

    if (sortByDate) {
      playlists.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    } else {
      playlists.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    return playlists;
  }

  /// Get playlist by ID
  static AppPlaylist? getPlaylist(String id) {
    _ensureInitialized();
    return _playlistBox.get(id);
  }

  /// Update playlist
  static Future<void> updatePlaylist(AppPlaylist playlist) async {
    _ensureInitialized();
    await _playlistBox.put(playlist.id, playlist);
    log('📝 Updated playlist: ${playlist.name}');
  }

  /// Delete playlist
  static Future<void> deletePlaylist(String id) async {
    _ensureInitialized();
    await _playlistBox.delete(id);
    log('🗑️ Deleted playlist: $id');
  }

  /// Add song to playlist
  static Future<bool> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;

    playlist.addSong(songId);
    await updatePlaylist(playlist);
    return true;
  }

  /// Add multiple songs to playlist
  static Future<bool> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;

    for (final songId in songIds) {
      playlist.addSong(songId);
    }

    await updatePlaylist(playlist);
    return true;
  }

  /// Remove song from playlist
  static Future<bool> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;

    playlist.removeSong(songId);
    await updatePlaylist(playlist);
    return true;
  }

  /// Remove multiple songs from playlist
  static Future<bool> removeSongsFromPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;

    for (final songId in songIds) {
      playlist.removeSong(songId);
    }

    await updatePlaylist(playlist);
    return true;
  }

  /// Clear all songs from playlist
  static Future<bool> clearPlaylist(String playlistId) async {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;

    playlist.clearSongs();
    await updatePlaylist(playlist);
    return true;
  }

  /// Check if song is in playlist
  static bool isSongInPlaylist({
    required String playlistId,
    required String songId,
  }) {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    return playlist?.containsSong(songId) ?? false;
  }

  /// Get songs in playlist
  static List<String> getPlaylistSongs(String playlistId) {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    return playlist?.songIds ?? [];
  }

  /// Search playlists by name
  static List<AppPlaylist> searchPlaylists(String query) {
    _ensureInitialized();

    if (query.isEmpty) return getAllPlaylists();

    return _playlistBox.values
        .where(
          (playlist) =>
              playlist.name.toLowerCase().contains(query.toLowerCase()) ||
              (playlist.description?.toLowerCase() ?? '').contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }

  /// Reorder songs in playlist (following Flutter's onReorder convention)
static Future<bool> reorderPlaylistSongs({
  required String playlistId,
  required int oldIndex,
  required int newIndex,
}) async {
  _ensureInitialized();

  try {
    final playlist = _playlistBox.get(playlistId);
    if (playlist == null) {
      log('❌ Playlist not found: $playlistId');
      return false;
    }

    final songs = playlist.songIds;
    if (oldIndex < 0 || oldIndex >= songs.length) return false;
    if (newIndex < 0 || newIndex >= songs.length) return false;
    if (oldIndex == newIndex) return true;

    // Correct reorder: remove first, then insert at newIndex
    final movedId = songs.removeAt(oldIndex);
    songs.insert(newIndex, movedId);

    await _playlistBox.put(playlistId, playlist);
    log('✅ Reordered playlist: ${playlist.name}');
    return true;
  } catch (e) {
    log('❌ Error reordering: $e');
    return false;
  }
}

  /// Get playlist count
  static int get playlistCount {
    _ensureInitialized();
    return _playlistBox.length;
  }

  /// Get total song count across all playlists
  static int get totalSongsInAllPlaylists {
    _ensureInitialized();
    return _playlistBox.values.fold(
      0,
      (total, playlist) => total + playlist.songIds.length,
    );
  }

  /// Export playlist data (for backup/sharing)
  static Map<String, dynamic> exportPlaylist(String playlistId) {
    _ensureInitialized();

    final playlist = getPlaylist(playlistId);
    if (playlist == null) throw Exception('Playlist not found');

    return playlist.toJson();
  }

  /// Import playlist data
  static Future<AppPlaylist> importPlaylist(Map<String, dynamic> data) async {
    _ensureInitialized();

    final playlist = AppPlaylist(
      id: data['id'] ?? const Uuid().v4(),
      name: data['name'] ?? 'Imported Playlist',
      description: data['description'],
      songIds: List<String>.from(data['songIds'] ?? []),
    );

    await _playlistBox.put(playlist.id, playlist);
    return playlist;
  }

  /// Clean up duplicate songs in all playlists
  static Future<void> cleanDuplicateSongs() async {
    _ensureInitialized();

    for (final playlist in _playlistBox.values) {
      final uniqueSongs = <String>{};
      final cleanSongIds = <String>[];

      for (final songId in playlist.songIds) {
        if (!uniqueSongs.contains(songId)) {
          uniqueSongs.add(songId);
          cleanSongIds.add(songId);
        }
      }

      if (cleanSongIds.length != playlist.songIds.length) {
        final removedCount = playlist.songIds.length - cleanSongIds.length;
        playlist.songIds.clear();
        playlist.songIds.addAll(cleanSongIds);
        await updatePlaylist(playlist);
        log('🧹 Removed $removedCount duplicate songs from ${playlist.name}');
      }
    }
  }

  /// Backup all playlists
  static Map<String, dynamic> backupAllPlaylists() {
    _ensureInitialized();

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'playlistCount': playlistCount,
      'totalSongs': totalSongsInAllPlaylists,
      'playlists': _playlistBox.values.map((p) => p.toJson()).toList(),
    };
  }

  /// Restore from backup
  static Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    _ensureInitialized();

    // Clear existing data
    await _playlistBox.clear();

    // Restore playlists
    final playlists = backup['playlists'] as List<dynamic>;
    for (final playlistData in playlists) {
      await importPlaylist(Map<String, dynamic>.from(playlistData));
    }

    log('🔄 Restored ${playlists.length} playlists from backup');
  }

  /// Helper method to ensure service is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('AppPlaylistService not initialized. Call init() first.');
    }
  }

  /// Close Hive boxes (call when app is closing)
  static Future<void> close() async {
    if (_isInitialized) {
      await _playlistBox.close();
      await _settingsBox.close();
      _isInitialized = false;
      log('🔒 AppPlaylistService closed');
    }
  }
}
