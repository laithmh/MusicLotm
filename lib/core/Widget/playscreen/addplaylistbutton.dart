import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/timeandshufell.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
                  builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        content: SizedBox(
                          height: 900.h,
                          width: 400.w,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount:
                                      playlistcontroller.playlists.length,
                                  itemBuilder: (BuildContext context, index) {
                                    PlaylistModel playlist =
                                        playlistcontroller.playlists[index];
                                    return GetBuilder<Playlistcontroller>(
                                      builder: (controller) {
                                        return CheckboxListTile(
                                          title: Text(
                                              playlist.playlist.toUpperCase()),
                                          checkColor: Colors.white,
                                          activeColor: Colors.blueGrey,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          checkboxShape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          value: controller.listplaylisid
                                              .contains(playlist.id),
                                          onChanged: (selected) {
                                            controller.onPlaylistSelected(
                                                selected, playlist.id);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: const Text("cancel"),
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      playlistcontroller.addSongsToPlaylist(
                                          songHandler.mediaItem.value!);

                                      Get.back();
                                    },
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: const Text("save"),
                                  ),
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
            setloop: () {
              songHandler.isloop.value = !songHandler.isloop.value;
              songHandler.looping();
            },
            shuffle: () {},
          );
        });
  }
}
