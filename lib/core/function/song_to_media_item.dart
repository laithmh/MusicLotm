import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

SongModel? getsongsartwork(SongModel songModel, List<SongModel> localSongList) {
  try {
    return localSongList.firstWhere(
      (element) => element.displayNameWOExt == songModel.displayNameWOExt,
      orElse: () => songModel, // Return original if not found
    );
  } catch (e) {
    debugPrint('Error finding song artwork: $e');
    return songModel;
  }
}

Future<MediaItem?> songToMediaItem(SongModel song) async {
  try {
    // Validate required fields
    if (song.uri == null || song.uri!.isEmpty) {
      debugPrint('Song ${song.title} has no valid URI');
      return null;
    }

    if (song.duration == null || song.duration! <= 0) {
      debugPrint('Song ${song.title} has invalid duration');
      return null;
    }

    return MediaItem(
      id: song.uri.toString(), // Changed back to toString() for consistency
      title: song.displayNameWOExt,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      duration: Duration(milliseconds: song.duration!),
      displayDescription: song.id.toString(),
      genre: song.dateAdded.toString(),
      // artUri: song.albumId != null 
      //     ? Uri.parse('content://media/external/audio/albumart/${song.albumId}')
      //     : null,
      extras: {
        'album_id': song.albumId,
        'date_added': song.dateAdded,
        'size': song.size,
        'song_id': song.id, // Added for easier lookup
        'album_art_id': song.albumId, // Store for artwork retrieval
      },
    );
  } catch (e) {
    debugPrint('Error converting SongModel to MediaItem: $e');
    return null;
  }
}