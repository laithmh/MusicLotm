import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

SongModel getsongsartwork(SongModel songModel, List<SongModel> localSongList) {
  late SongModel songartwork = localSongList.firstWhere(
      (element) => element.displayNameWOExt == songModel.displayNameWOExt);

  return songartwork;
}

Future<MediaItem> songToMediaItem(SongModel song) async {
  try {
    return MediaItem(
        id: song.uri.toString(),
        title: song.displayNameWOExt,
        artist: song.artist,
        duration: Duration(milliseconds: song.duration!),
        displayDescription: song.id.toString(),
        genre: song.dateAdded.toString());
  } catch (e) {
    debugPrint('Error converting SongModel to MediaItem: $e');

    return const MediaItem(id: '', title: 'Error', artist: 'Unknown');
  }
}
