import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transparent_image/transparent_image.dart';

class Songlistwidget extends StatelessWidget {
  const Songlistwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Navigatorcontroller navigator = Get.find();
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();

    List<String> dropdownItems = ['titelAS', 'titelDS', 'dateAS', 'dateDS'];

    return haspermission.isTrue
        ? Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.w,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "songs : ${songscontroller.songs.length}",
                      style: TextStyle(fontSize: 45.sp),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        icon: const Icon(Icons.sort),
                        onChanged: (String? newValue) async {
                          sort(
                              song: songscontroller.songs, sortType: newValue!);
                          sortSongModel(
                              song: songscontroller.songModels,
                              sortType: newValue);
                          songscontroller.isallmusic.value = false;

                          songscontroller.update();
                          log(newValue);
                          await box.put("sortTypeAllMusic", newValue);
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
                  ],
                ),
                const Divider(),
                SizedBox(
                  height: 10.w,
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    width: double.maxFinite,
                    child: GetBuilder<Songscontroller>(
                      builder: (controller) {
                        List<MediaItem> audio = controller.songs;
                        return ScrollablePositionedList.builder(
                          itemScrollController: controller.itemScrollController,
                          shrinkWrap: true,
                          itemCount: audio.length,
                          itemBuilder: (BuildContext context, int index) {
                            
                            return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 10.w),
                                child: GetBuilder<Playlistcontroller>(
                                  builder: (pcontroller) {
                                    SongModel selectedsong =
                                        controller.songModels.firstWhere(
                                      (element) =>
                                          element.displayNameWOExt ==
                                          audio[index].title,
                                    );
                                    return Neubox(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ListTile(
                                        trailing: pcontroller.selectionMode
                                            ? Checkbox(
                                                checkColor: Colors.white,
                                                activeColor: Colors.blueGrey,
                                                value: pcontroller.listsongsid
                                                    .contains(selectedsong
                                                        .displayNameWOExt),
                                                onChanged: (selected) {
                                                  pcontroller.onSongstSelected(
                                                      selected,
                                                      selectedsong
                                                          .displayNameWOExt);
                                                },
                                              )
                                            : audio[index] ==
                                                    songHandler.mediaItem.value
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      MiniMusicVisualizer(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .inversePrimary,
                                                        width: 4,
                                                        height: 15,
                                                        radius: 2,
                                                        animate: songHandler
                                                            .playbackState
                                                            .value
                                                            .playing,
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                        title: Text(
                                          audio[index].title,
                                          style: const TextStyle(
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        subtitle: Text("${audio[index].artist}",
                                            style: const TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        leading: audio[index].artUri == null ||
                                                audio[index].artUri ==
                                                    Uri.parse("null")
                                            ? const Icon(
                                                Icons.music_note,
                                              )
                                            : FadeInImage(
                                                height: 45,
                                                width: 45,
                                                filterQuality:
                                                    FilterQuality.high,
                                                image: FileImage(File.fromUri(
                                                    audio[index].artUri!)),
                                                placeholder: MemoryImage(
                                                    kTransparentImage),
                                                fit: BoxFit.cover,
                                              ),
                                        onTap: () async {
                                          if (controller.isallmusic.isFalse) {
                                            await controller.handelallsongs();
                                          }
                                          await songHandler
                                              .skipToQueueItem(index);

                                          controller.isallmusic.value = true;
                                          controller.isplaylist.value = false;
                                          controller.isfavorite.value = false;
                                          controller.issearch.value = false;
                                          playlistcontroller.newplaylistID = 0;
                                          box.putAll({
                                            "isallmusic":
                                                controller.isallmusic.value,
                                            "isplaylist":
                                                controller.isplaylist.value,
                                            "isfavorite":
                                                controller.isfavorite.value,
                                          });

                                          navigator.changepage(2);
                                          await songHandler.play();
                                        },
                                        onLongPress: () {
                                          playlistcontroller.toggleSelection();
                                          playlistcontroller.listplaylisid
                                              .clear();
                                          playlistcontroller.listsongsid
                                              .clear();
                                        },
                                      ),
                                    );
                                  },
                                ));
                          },
                        );
                      },
                    ))
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
