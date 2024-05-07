import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';

class Searchcontroller extends GetxController {
  Songscontroller songscontroller = Get.put(Songscontroller());
  final controller = TextEditingController();

  List<MediaItem> filteredData = [];

  void filterData(String songname) {
    filteredData = songscontroller.songs
        .where((item) =>
            item.title.toLowerCase().startsWith(songname.toLowerCase()))
        .toList();
    update();
  }

  @override
  void onClose() {
    controller.clear();
    super.onClose();
  }
}