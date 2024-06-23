import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/showdialog.dart';
import 'package:musiclotm/core/Widget/timeandshufell.dart';
import 'package:musiclotm/main.dart';

class Addtoplaylistbutton extends StatelessWidget {
  const Addtoplaylistbutton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Playlistcontroller playlistcontroller = Get.find();

    return StreamBuilder<Duration>(
        stream: AudioService.position,
        builder: (context, snapshot) {
          Duration? position = snapshot.data;
          return Timerow(
            addtoplaylist: () {
              showDialog(
                  context: context,
                  builder: (context) => CustomAlertDialog(
                        onPressed: () {
                          playlistcontroller
                              .addSongsToPlaylist(songHandler.mediaItem.value!);

                          Get.back();
                        },
                      ));
            },
            currenttime: position == null
                ? "0:00:00"
                : position.toString().split(".")[0],
            duraion: audioPlayer.duration == null
                ? "0:00:00"
                : audioPlayer.duration.toString().split(".")[0],
            setloop: () {
              songHandler.isloop.value = !songHandler.isloop.value;
              songHandler.looping();
            },
            shuffle: ()  {
               songHandler.toggleShuffle();
            },
          );
        });
  }
}
