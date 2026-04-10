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
    final SongHandler songHandler = Get.find<SongHandler>();
    final AudioPlayer audioPlayer = Get.find<AudioPlayer>();

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

            // Clear previous selections before opening the dialog
            playlistcontroller.clearSelections();

            // Show the playlist selection dialog
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                onPressed: () async {
                  // The controller handles validations, duplicates, and closing the dialog
                  await playlistcontroller.addSongToSelectedPlaylists(
                    currentSong.id,
                  );
                  Get.back(); // Close the dialog
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
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
