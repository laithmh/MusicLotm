import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/main.dart';
import 'package:transparent_image/transparent_image.dart';

class Playlistpage extends StatelessWidget {
  const Playlistpage({super.key});

  @override
  Widget build(BuildContext context) {
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();
    Navigatorcontroller navigator = Get.find();
    List<String> dropdownItems = ['titelAS', 'titelDS', 'dateAS', 'dateDS'];
    return haspermission.value
        ? FutureBuilder<List<MediaItem>>(
            future: playlistcontroller
                .loadsongplaylist(playlistcontroller.playlistId),
            initialData: const [],
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Scaffold(
                  bottomNavigationBar: const Navigationbarwidget(),
                  backgroundColor: Theme.of(context).colorScheme.background,
                  appBar: AppBar(
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(right: 10.sp),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const Icon(Icons.sort),
                            onChanged: (String? newValue) async {
                              sort(
                                  song: playlistcontroller.mediasongs,
                                  sortType: newValue!);
                              songscontroller.isplaylist.value = false;

                              playlistcontroller.update();
                              log(newValue);
                              await box.put("sortTypePlaylists", newValue);
                            },
                            items: dropdownItems
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                    title: Text(
                      playlistcontroller
                          .playlists[playlistcontroller.playlistindex].playlist,
                      style: TextStyle(
                          letterSpacing: 5,
                          fontWeight: FontWeight.bold,
                          fontSize: 75.sp),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    centerTitle: true,
                  ),
                  body: GetBuilder<Playlistcontroller>(
                    builder: (controller) {
                      List<MediaItem> audio = controller.mediasongs;
                      return ListView.builder(
                        itemCount: audio.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(7),
                            child: Neubox(
                              borderRadius: BorderRadius.circular(12),
                              child: Slidable(
                                endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          controller.removeSongFromPlaylist(
                                              controller.playlistId,
                                              controller.mediasongs[index]);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        icon: Icons.delete,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      )
                                    ]),
                                child: ListTile(
                                  trailing: audio[index] ==
                                          songHandler.mediaItem.value
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MiniMusicVisualizer(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                              width: 4,
                                              height: 15,
                                              radius: 2,
                                              animate: songHandler
                                                  .playbackState.value.playing,
                                            ),
                                          ],
                                        )
                                      : null,
                                  title: Text(
                                    audio[index].title,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  subtitle: Text(audio[index].artist!,
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis)),
                                  leading: audio[index].artUri == null || audio[index].artUri== Uri.parse("null")
                                      ? const Icon(
                                          Icons.music_note,
                                        )
                                      : FadeInImage(
                                          height: 45,
                                          width: 45,
                                          filterQuality: FilterQuality.high,
                                          image: FileImage(File.fromUri(
                                              audio[index].artUri!)),
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          fit: BoxFit.cover,
                                        ),
                                  onTap: () async {
                                    if (songscontroller.isplaylist.isFalse ||
                                        playlistcontroller.playlistId !=
                                            playlistcontroller.newplaylistID) {
                                      await playlistcontroller
                                          .handelplaylists();
                                    }
                                    await songHandler.skipToQueueItem(index);
                                    await songHandler.play();
                                    songscontroller.isallmusic.value = false;
                                    songscontroller.isplaylist.value = true;
                                    songscontroller.isfavorite.value = false;
                                    box.putAll({
                                      "isallmusic":
                                          songscontroller.isallmusic.value,
                                      "isplaylist":
                                          songscontroller.isplaylist.value,
                                      "isfavorite":
                                          songscontroller.isfavorite.value,
                                    });
                                    Get.back();
                                    navigator.changepage(2);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ));
            },
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
