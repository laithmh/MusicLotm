import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:musiclotm/core/data/songdata.dart';
import 'package:musiclotm/core/services/get_song_art.dart';
import 'package:on_audio_query/on_audio_query.dart';

SongModel getsongsartwork(SongModel songModel, List<SongModel> localSongList) {
  late SongModel songartwork = localSongList.firstWhere(
      (element) => element.displayNameWOExt == songModel.displayNameWOExt);

  return songartwork;
}

MediaItem songDataToMediaItem(Songdata song) {
  return MediaItem(
      id: song.id,
            artUri: Uri.parse(song.artUri!),
            title: song.title,
            artist: song.artist,
            duration: Duration(seconds: song.duration!),
            displayDescription: song.displayDescription);
}

Songdata mediaItemtoSongData(MediaItem song) {
  return Songdata(
      id: song.id,
      artUri: song.artUri.toString(),
      title: song.title,
      artist: song.artist,
      duration: song.duration!.inSeconds,
      displayDescription: song.displayDescription);
}

Future<MediaItem> songToMediaItem(SongModel song) async {
  try {
    final Uri? art = await getSongArt(
      id: song.id,
      type: ArtworkType.AUDIO,
      quality: 100,
      size: 300,
    );

    return MediaItem(
      id: song.uri.toString(),
      artUri: art,
      title: song.displayNameWOExt,
      artist: song.artist,
      duration: Duration(milliseconds: song.duration!),
      displayDescription: song.id.toString(),
    );
  } catch (e) {
    debugPrint('Error converting SongModel to MediaItem: $e');

    return const MediaItem(id: '', title: 'Error', artist: 'Unknown');
  }
}
