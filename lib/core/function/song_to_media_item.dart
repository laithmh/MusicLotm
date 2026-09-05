import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:on_audio_query/on_audio_query.dart';

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
      id: song.uri.toString(),
      title: song.displayNameWOExt,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      duration: Duration(milliseconds: song.duration!),
      displayDescription: song.id.toString(),
      genre: song.dateAdded.toString(),
      extras: {
        'album_id': song.albumId,
        'date_added': song.dateAdded,
        'size': song.size,
        'song_id': song.id,
        'album_art_id': song.albumId,
      },
    );
  } catch (e) {
    debugPrint('Error converting SongModel to MediaItem: $e');
    return null;
  }
}