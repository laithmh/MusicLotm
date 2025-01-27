import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/function/sort.dart';
import 'package:musiclotm/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();
    Navigatorcontroller navigator = Get.find();
    List<String> dropdownItems = ['titelAS', 'titelDS', 'dateAS', 'dateDS'];
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
                  sort(song: playlistcontroller.favorites, sortType: newValue!);
                  songscontroller.isfavorite.value = false;
                  playlistcontroller.update();
                  log(newValue);
                  await box.put("sortTypeFavorite", newValue);
                },
                items:
                    dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "F A V O R I T E",
          style: TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<RxList<MediaItem>>(
        future: playlistcontroller.loadefavorites(),
        initialData: const <MediaItem>[].obs,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<MediaItem> audio = snapshot.data ?? [];
          return ListView.builder(
            itemCount: audio.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  key: Key(audio[index].id),
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                  child: GetBuilder<Playlistcontroller>(
                    builder: (controller) {
                      return Neubox(
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          trailing: audio[index] == songHandler.mediaItem.value
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
                          subtitle: Text(audio[index].artist!),
                          leading: QueryArtworkWidget(
                            id: int.tryParse(audio[index].displayDescription!)!,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(
                              Icons.music_note,
                            ),
                          ),
                          onTap: () async {
                            if (songscontroller.isfavorite.isFalse) {
                              await playlistcontroller.handelfavorite();
                            }
                            songHandler.skipToQueueItem(index);
                            songscontroller.isallmusic.value = false;
                            songscontroller.isplaylist.value = false;
                            songscontroller.isfavorite.value = true;
                            box.putAll({
                              "isallmusic": songscontroller.isallmusic.value,
                              "isplaylist": songscontroller.isplaylist.value,
                              "isfavorite": songscontroller.isfavorite.value,
                            });
                            Get.back();
                            navigator.changepage(2);
                            await songHandler.play();
                          },
                        ),
                      );
                    },
                  ));
            },
          );
        },
      ),
    );
  }
}
