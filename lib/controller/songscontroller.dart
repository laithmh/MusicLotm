import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/core/function/song_to_media_item.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

RxBool haspermission = false.obs;

class Songscontroller extends GetxController {
  AnimationControllerX animationController = Get.find();

  final ItemScrollController itemScrollController = ItemScrollController();
  late RxBool isplaylist = false.obs;
  late RxBool isfavorite = false.obs;
  late RxBool isallmusic = true.obs;
  late RxBool issearch = true.obs;

  String? sortypeallMusic;
  String? sortypePlaylists;
  String? sortypeFavorite;
  late int position = 0;

  List<SongModel> songModels = [];
  late List<MediaItem> songs = <MediaItem>[].obs;
  RxInt currentSongPlayingIndex = 0.obs;

  Future<void> requestSongPermission() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
        Permission.notification
      ].request();

      if (statuses[Permission.storage]!.isGranted ||
          statuses[Permission.audio]!.isGranted) {
        await loadSongs();
        haspermission.value = statuses[Permission.storage]!.isGranted;
      } else {
        Future.delayed(
          const Duration(seconds: 60),
          () async => await openAppSettings(),
        );

        log('Permission not granted. Please enable storage access.');
      }
    } catch (e) {
      debugPrint('Error requesting song permissions: $e');
    }
  }

  handelallsongs() async {
    await songHandler.initSongs(songs: songs);
    animationController.reset();
  }

  Future<List<MediaItem>> getSongs() async {
    try {
      final OnAudioQuery onAudioQuery = OnAudioQuery();

      songModels = await onAudioQuery.querySongs(
        sortType: audioQuerySongSortType(sortypeallMusic!),
        orderType: audioQueryOrderType(sortypeallMusic!),
      );

      List<MediaItem> songs = await Future.wait(songModels.map((song) async {
        return songToMediaItem(song);
      }).toList());

      return songs;
    } catch (e) {
      debugPrint('Error fetching songs: $e');
      return <MediaItem>[].obs;
    }
  }

  Future<void> loadSongs() async {
    try {
      songs = await getSongs();

      update();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  scroll() {
    if (songHandler.mediaItem.value == null) {
      itemScrollController.scrollTo(
          index: 0, duration: const Duration(seconds: 2), curve: Curves.easeIn);
    } else {
      int index = songs.indexOf(songHandler.mediaItem.value!);
      itemScrollController.scrollTo(
          index: index,
          duration: const Duration(seconds: 2),
          curve: Curves.easeIn);
    }

    update();
  }

  @override
  void onInit() async {
    position = await box.get("position") ?? 0;
    currentSongPlayingIndex.value = await box.get("currentIndex") ?? 0;
    isplaylist.value = await box.get("isplaylist") ?? false;
    isfavorite.value = await box.get("isfavorite") ?? false;
    isallmusic.value = await box.get("isallmusic") ?? true;

    sortypeallMusic = await box.get("sortTypeAllMusic") ?? "titelAS";
    sortypeFavorite = await box.get("sortTypePlaylists") ?? "titelAS";
    sortypePlaylists = await box.get("sortTypeFavorite") ?? "titelAS";

    log("$sortypeallMusic");

    super.onInit();
  }
}
