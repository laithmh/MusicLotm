import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';


import 'package:musiclotm/core/services/song_to_media_item.dart';
import 'package:musiclotm/main.dart';

import 'package:on_audio_query/on_audio_query.dart';

class Playlistcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  final StreamController<RxList<MediaItem>> myStreamController =
      StreamController<RxList<MediaItem>>();

  Stream<RxList<MediaItem>> get myplaylistStream => myStreamController.stream;

  
  final controller = TextEditingController();

  final OnAudioQuery audioQuery = OnAudioQuery();
  RxList<MediaItem> mediasongs = <MediaItem>[].obs;
  late List<PlaylistModel> playlists = [];
  late PlaylistModel? myPlaylist;
  late List<SongModel> playlistsongs = [];
  late int playlistindex = 0;
  late int playlistId = 0;

  RxInt currentSongPlayingIndex = 0.obs;

  handelplaylists() async {
    await songHandler.initSongs(songs: mediasongs);
  }

  Future<void> createNewPlaylist() async {
    final String playlistName = controller.text;

    final bool playlistCreated = await audioQuery.createPlaylist(
      playlistName,
    );
    playlists = await audioQuery.queryPlaylists();

    if (playlistCreated) {
      log('Playlist created successfully!');
    } else {
      log('Failed to create the playlist.');
    }
    update();
  }

  Future<void> addSongsToPlaylist(SongModel song) async {
    playlists = await audioQuery.queryPlaylists();
    myPlaylist = playlists.firstWhere(
      (playlist) => playlist.playlist == playlists[playlistindex].playlist,
    );
    playlistId = myPlaylist!.id;

    final bool added = await audioQuery.addToPlaylist(playlistId, song.id);
    if (added) {
      log('Song added to the playlist successfully!');
      log("${song.id}");
    } else {
      log('Failed to add the song to the playlist.');
    }
    update();
  }

  Future<List<MediaItem>> loadsongplaylist(int playlistid) async {
    RxList<MediaItem> songs = <MediaItem>[].obs;
    try {
      playlistsongs = await audioQuery.queryAudiosFrom(
          AudiosFromType.PLAYLIST, playlistid,
          orderType: OrderType.ASC_OR_SMALLER);

      for (final SongModel songModel in playlistsongs) {
        final MediaItem song = await songToMediaItem(
            getsongsartwork(songModel, songscontroller.songModels));
        songs.add(song);
        myStreamController.add(songs);
      }
      mediasongs = songs;
      return songs;
    } catch (e) {
      debugPrint('Error fetching songs: $e');
      return <MediaItem>[].obs;
    }
  }

  Future<void> loadplaylist() async {
    playlists = await audioQuery.queryPlaylists();
  }

  deleteplaylist(int index, int playlistid) async {
    playlists.removeAt(index);
    await audioQuery.removePlaylist(playlistid);
    update();
  }

  @override
  void onInit() async {
    await loadplaylist();

    super.onInit();
  }

  @override
  void onClose() {
    myStreamController.close();
    controller.dispose();
    super.onClose();
  }
}
