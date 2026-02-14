import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/Widget/showdialog.dart';
import 'package:musiclotm/core/Widget/timeandshufell.dart';

class Addtoplaylistbutton extends StatelessWidget {
  const Addtoplaylistbutton({super.key});

  @override
  Widget build(BuildContext context) {
    final Playlistcontroller playlistcontroller = Get.find();
    SongHandler songHandler = Get.find<SongHandler>();
    AudioPlayer audioPlayer = Get.find<AudioPlayer>();
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final Duration? position = snapshot.data;
        final currentSong = songHandler.mediaItem.value;

        return Timerow(
          addtoplaylist: () {
            if (currentSong == null) {
              Get.snackbar('No Song', 'No song is currently playing');
              return;
            }

            // Clear previous selections
            playlistcontroller.clearSelections();

            // Show the playlist selection dialog
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                onPressed: () async {
                  if (playlistcontroller.selectedPlaylistIds.isEmpty) {
                    Get.snackbar('Info', 'Please select at least one playlist');
                    return;
                  }

                  try {
                    // Add current song to selected playlists
                    for (final playlistId
                        in playlistcontroller.selectedPlaylistIds) {
                      await playlistcontroller.addSongToPlaylist(
                        playlistId: playlistId,
                        songId: currentSong.id,
                        showNotification: false,
                      );
                    }

                    final count = playlistcontroller.selectedPlaylistIds.length;

                    Get.snackbar(
                      'Success',
                      'Added to $count playlist${count > 1 ? 's' : ''}',
                    );

                    playlistcontroller.clearSelections();
                    Get.back();
                  } catch (e) {
                    log('Error adding song to playlists: $e');
                    Get.snackbar('Error', 'Failed to add song to playlists');
                  }
                },
              ),
            );
          },
          currenttime: position == null ? "0:00:00" : _formatDuration(position),
          duraion: audioPlayer.duration == null
              ? "0:00:00"
              : _formatDuration(audioPlayer.duration!),
          setloop: () async {
            await songHandler.toggleLoop();
          },
          shuffle: () async {
            await songHandler.toggleShuffle();
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
