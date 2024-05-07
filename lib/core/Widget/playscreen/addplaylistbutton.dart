import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

import 'package:musiclotm/core/Widget/timeandshufell.dart';
import 'package:musiclotm/main.dart';

class Addtoplaylistbutton extends StatelessWidget {
  const Addtoplaylistbutton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Playlistcontroller playlistcontroller = Get.put(Playlistcontroller());
    Songscontroller songscontroller = Get.put(Songscontroller());
    return StreamBuilder<Duration>(
        stream: AudioService.position,
        builder: (context, snapshot) {
          Duration? position = snapshot.data;
          return Timerow(
            addtoplaylist: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        content: SizedBox(
                          height: 400,
                          width: 400,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount:
                                      playlistcontroller.playlists.length,
                                  itemBuilder: (BuildContext context, index) {
                                    final RxList<bool> checkedItems =
                                        List.generate(
                                                index + 1, (index) => false,
                                                growable: false)
                                            .obs;
                                    return Obx(
                                      () => CheckboxListTile(
                                        title: Text(playlistcontroller
                                            .playlists[index].playlist),
                                        checkColor: Colors.white,
                                        activeColor: Colors.blueGrey,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        checkboxShape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        value: checkedItems[index],
                                        onChanged: (value) {
                                          checkedItems[index] = value!;
                                          if (value = true) {
                                            playlistcontroller.playlistindex =
                                                index;
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      playlistcontroller.addSongsToPlaylist(
                                          songscontroller.songModels[
                                              songscontroller
                                                  .currentSongPlayingIndex
                                                  .value]);

                                      log("===========${playlistcontroller.loadsongplaylist(playlistcontroller.playlistId)}");

                                      Get.back();
                                    },
                                    child: const Text("save"),
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text("cancel"),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ));
            },
            currenttime: position == null
                ? "0:00:00"
                : position.toString().split(".")[0],
            duraion: songHandler.audioPlayer.duration == null
                ? "0:00:00"
                : songHandler.audioPlayer.duration.toString().split(".")[0],
            setloop: () {},
            shuffle: () {},
          );
        });
  }
}
