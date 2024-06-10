import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/core/services/song_to_media_item.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Playlistcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  AnimationControllerX animationController = Get.find();
  final StreamController<RxList<MediaItem>> myStreamController =
      StreamController<RxList<MediaItem>>();

  Stream<RxList<MediaItem>> get myplaylistStream => myStreamController.stream;

  final controller = TextEditingController();

  final OnAudioQuery audioQuery = OnAudioQuery();
  RxList<MediaItem> mediasongs = <MediaItem>[].obs;
  RxList<MediaItem> favorites = <MediaItem>[].obs;

  Map<dynamic, dynamic> isfavorite = {};
  late List<PlaylistModel> playlists = [];

  late int playlistindex = 0;
  late List<int> listplaylisid = [];
  late List<String> listsongsid = [];

  bool selectionMode = false;
  late int playlistId = 0;
  late int newplaylistID = 0;

  handelplaylists() async {
    newplaylistID = playlistId;
    await songHandler.initSongs(
      songs: mediasongs,
    );
    animationController.reset();
  }

  void onPlaylistSelected(bool? selected, int playlistId) {
    if (selected == true) {
      listplaylisid.add(playlistId);
    } else {
      listplaylisid.remove(playlistId);
    }
    log("$listplaylisid");
    update();
  }

  void onSongstSelected(bool? selected, String songtitel) {
    if (selected == true) {
      listsongsid.add(songtitel);
    } else {
      listsongsid.remove(songtitel);
    }
    log("$listsongsid");
    update();
  }

  void toggleSelection() {
    if (selectionMode) {
      selectionMode = false;
    } else {
      selectionMode = true;
    }
    update();
    animationController.update();
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
    playlists = await audioQuery.queryPlaylists();
    for (int playlistId in listplaylisid) {
      List<SongModel> playlistSongs =
          await audioQuery.queryAudiosFrom(AudiosFromType.PLAYLIST, playlistId);
      bool songExists = playlistSongs.any(
        (element) {
          return element.displayNameWOExt == mediasong.title;
        },
      );
      if (songExists) {
        Get.snackbar("title",
            "Song ID ${mediasong.title} already exists in playlist ID $playlistId.");
      } else {
        SongModel song = songscontroller.songModels.firstWhere(
            (element) => element.displayNameWOExt == mediasong.title);
        final bool added = await audioQuery.addToPlaylist(playlistId, song.id);
        if (added) {
          Get.snackbar("",
              "Song ID ${mediasong.title} added to playlist ID $playlistId successfully!");
        } else {
          Get.snackbar("",
              "Failed to add song ID ${mediasong.title} to playlist ID $playlistId.");
        }
      }
    }

    update();
  }

  Future<void> addSongsToSelectedPlaylists() async {
    for (int playlistId in listplaylisid) {
      for (String songtitel in listsongsid) {
        List<SongModel> playlistSongs = await audioQuery.queryAudiosFrom(
            AudiosFromType.PLAYLIST, playlistId);
        bool songExists =
            playlistSongs.any((song) => song.displayNameWOExt == songtitel);
        SongModel songid = songscontroller.songModels
            .firstWhere((element) => element.displayNameWOExt == songtitel);

        if (!songExists) {
          bool result = await audioQuery.addToPlaylist(playlistId, songid.id);
          if (result) {
            Get.snackbar("",
                "Song ID $songtitel added to playlist ID $playlistId successfully!");
          } else {
            Get.snackbar("",
                "Failed to add song ID $songtitel to playlist ID $playlistId.");
          }
        } else {
          Get.snackbar("title",
              "Song ID $songtitel already exists in playlist ID $playlistId.");
        }
      }
    }
  }

  Future<RxList<MediaItem>> loadsongplaylist(int playlistid) async {
    try {
      List<SongModel> playlistsongs = await audioQuery.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        playlistid,
        sortType: audioQuerySongSortType(songscontroller.sortypePlaylists!),
        orderType: audioQueryOrderType(songscontroller.sortypePlaylists!),
      );

      mediasongs.value = await Future.wait(playlistsongs.map((song) async {
        return await songToMediaItem(
            getsongsartwork(song, songscontroller.songModels));
      }).toList());
      mediasongs.assignAll(
          sort(song: mediasongs, sortType: songscontroller.sortypePlaylists!));
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

  Future<void> removeSongFromPlaylist(
      int playlistId, MediaItem mediasong) async {
    SongModel song = songscontroller.songModels
        .firstWhere((element) => element.displayNameWOExt == mediasong.title);
    bool done = await audioQuery.removeFromPlaylist(playlistId, song.id);
    mediasongs.removeWhere(
      (element) => element.title == song.displayNameWOExt,
    );
    if (done) {
      log("removed");
    }
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
    try {
      List keys = isfavorite.keys.toList();
      favorites.clear();
      for (var i = 0; i < isfavorite.length; i++) {
        MediaItem song = songscontroller.songs
            .firstWhere((element) => element.id == keys[i]);

        favorites.add(song);
      }

      favorites.assignAll(
          sort(song: favorites, sortType: songscontroller.sortypeFavorite!));
      return favorites;
    } catch (e) {
      return <MediaItem>[].obs;
    }
  }

  handelfavorite() async {
    await songHandler.initSongs(
      songs: favorites,
    );
    animationController.reset();
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
    playlistId = await box.get("playlistid") ?? 0;
    await loadsongplaylist(playlistId);
    isfavorite = await box.get("favorite") ?? {};
    await loadplaylist();

    await loadefavorites();

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
