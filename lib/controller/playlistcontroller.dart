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
  RxList<MediaItem> favorites = <MediaItem>[].obs;

  Map<dynamic, dynamic> isfavorite = {};
  late List<PlaylistModel> playlists = [];
  late PlaylistModel? myPlaylist;

  late List<SongModel> playlistsongs = [];
  late int playlistindex = 0;
  late int playlistId = 0;
  late int newplaylistID = 0;

  handelplaylists() async {
    newplaylistID = playlistId;
    await songHandler.initSongs(
      songs: mediasongs,
    );
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

  Future<void> addSongsToPlaylist(MediaItem mediasong) async {
    SongModel song = songscontroller.songModels
        .firstWhere((element) => element.displayNameWOExt == mediasong.title);

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

  Future<RxList<MediaItem>> loadsongplaylist(int playlistid) async {
    try {
      playlistsongs = await audioQuery.queryAudiosFrom(
          AudiosFromType.PLAYLIST, playlistid,
          orderType: OrderType.DESC_OR_GREATER,
          sortType: SongSortType.DATE_ADDED);

      mediasongs.value = await Future.wait(playlistsongs.map((song) async {
        return await songToMediaItem(
            getsongsartwork(song, songscontroller.songModels));
      }).toList());
      mediasongs.value = mediasongs.toSet().toList();

      return mediasongs;
    } catch (e) {
      debugPrint('Error fetching songs: $e');
      return <MediaItem>[].obs;
    }
  }

  Future<void> loadplaylist() async {
    playlists = await audioQuery.queryPlaylists();
  }

  Future<void> deleteplaylist(int index, int playlistid) async {
    playlists.removeAt(index);
    await audioQuery.removePlaylist(playlistid);
    update();
  }

  Future<void> removeSongFromPlaylist(int playlistId, SongModel audioId) async {
    await audioQuery.removeFromPlaylist(playlistId, audioId.id);
    mediasongs.removeWhere(
      (element) => element.title == audioId.displayNameWOExt,
    );
    playlistsongs.remove(audioId);
    update();
  }

  addfavorite(MediaItem song) {
    isfavorite[song.id] = true;
    box.put("favorite", isfavorite);
    update();
  }

  removefavorite(MediaItem song) {
    isfavorite.remove(song.id);
    box.put("favorite", isfavorite);
    update();
  }

  favoritetoggel(MediaItem song) {
    if (isfavorite.containsKey(song.id)) {
      removefavorite(song);
    } else {
      addfavorite(song);
    }
  }

  Future<RxList<MediaItem>> loadefavorites() async {
    List keys = isfavorite.keys.toList();
    favorites.clear();
    for (var i = 0; i < isfavorite.length; i++) {
      MediaItem song =
          songscontroller.songs.firstWhere((element) => element.id == keys[i]);

      favorites.add(song);
    }
    favorites.value = favorites.reversed.toList();

    return favorites;
  }

  handelfavorite() async {
    await songHandler.initSongs(
      songs: favorites,
    );
  }

  List<MediaItem> reOrder(int newIndex, int oldIndex, List<MediaItem> list) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final MediaItem item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    return list;
  }

  @override
  void onClose() {
    myStreamController.close();
    controller.dispose();
    super.onClose();
  }

  @override
  void onInit() async {
    await songscontroller.requestSongPermission();
    playlistId = await box.get("playlistid");
    await loadsongplaylist(playlistId);
    isfavorite = await box.get("favorite") ?? {};
    await loadplaylist();

    log("$playlistId");

    await loadefavorites();
    log("$favorites");
    if (songscontroller.isallmusic.isTrue) {
      await songHandler.initSongs(
        songs: songscontroller.songs,
      );
    } else if (songscontroller.isplaylist.isTrue) {
      await handelplaylists();
    } else if (songscontroller.isfavorite.isTrue) {
      await handelfavorite();
    }
    await songHandler
        .skipToQueueItem(songscontroller.currentSongPlayingIndex.value);
    await songHandler.seek(Duration(seconds: songscontroller.position));

    super.onInit();
  }
}
