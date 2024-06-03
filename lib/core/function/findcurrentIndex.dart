
// ignore_for_file: file_names

import 'dart:developer' ;

import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/main.dart';

void findCurrentSongPlayingIndex(String songId) {
  Songscontroller controller = Get.find();
  Playlistcontroller playlistcontroller = Get.find();
  int index = 0;
  if (controller.isallmusic.isTrue) {
    for (var e in controller.songs) {
      if (e.id == songId) {
        controller.currentSongPlayingIndex.value = index;
      }

      index++;
    }
  } else if (controller.isplaylist.isTrue) {
    for (var e in playlistcontroller.mediasongs) {
      if (e.id == songId) {
        controller.currentSongPlayingIndex.value = index;
      }

      index++;
    }
  } else if (controller.isfavorite.isTrue) {
    for (var e in playlistcontroller.favorites) {
      if (e.id == songId) {
        controller.currentSongPlayingIndex.value = index;
      }

      index++;
    }
  }

  playlistcontroller.update();
  log("${songHandler.audioPlayer.currentIndex}====${controller.currentSongPlayingIndex}");
  box.put("currentIndex", controller.currentSongPlayingIndex.value);
}
