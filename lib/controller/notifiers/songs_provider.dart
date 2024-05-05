import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/core/services/get_songs.dart';
import 'package:musiclotm/controller/song_handler.dart';


class Songscontroller extends GetxController {
  SongHandler songHandler = SongHandler();
  
  List<MediaItem> _songs = [];


  List<MediaItem> get songs => _songs;

 
  bool _isLoading = true;


  bool get isLoading => _isLoading;

  
  Future<void> loadSongs(SongHandler songHandler) async {
    try {
      
      _songs = await getSongs();

     
      await songHandler.initSongs(songs: _songs);

      _isLoading = false;

     
      update();
    } catch (e) {
      
      debugPrint('Error loading songs: $e');
      }
  }

  @override
  void onInit() async {
    await loadSongs(songHandler);
    super.onInit();
  }
}
