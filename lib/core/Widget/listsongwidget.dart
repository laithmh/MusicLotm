import 'dart:developer';

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

class Songlistwidget extends StatelessWidget {
  const Songlistwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Navigatorcontroller navigator = Get.find();
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();

    List<String> dropdownItems = [
      'titleASC',
      'titleDESC',
      'dateASC',
      'dateDESC'
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Songs: ${songscontroller.songs.length}",
                style: TextStyle(fontSize: 12.sp),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: const Icon(Icons.sort),
                  value: songscontroller.sortypeallMusic ?? 'titleASC',
                  onChanged: (String? newValue) async {
                    if (newValue == null) return;

                    sort(song: songscontroller.songs, sortType: newValue);
                    songscontroller.sortypeallMusic = newValue;
                    songscontroller.isallmusic.value = true;

                    songscontroller.update();
                    log(newValue);
                    await box.put("sortTypeAllMusic", newValue);
                  },
                  items: dropdownItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 10.sp),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const Divider(),
          SizedBox(height: 5.w),
          Expanded(
            child: GetX<Songscontroller>(
              builder: (controller) {
                List<MediaItem> audio = controller.songs;

                if (audio.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 30.sp,
                          color: Theme.of(context).disabledColor,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'No songs found',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ScrollablePositionedList.builder(
                  itemScrollController: controller.itemScrollController,
                  itemCount: audio.length,
                  itemBuilder: (BuildContext context, int index) {
                    final song = audio[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
                      child: Obx(() {
                        return Neubox(
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            trailing: playlistcontroller.isSelectionMode.value
                                ? Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Colors.blueGrey,
                                    value: playlistcontroller.selectedSongIds.contains(song.id),
                                    onChanged: (selected) {
                                      playlistcontroller.selectSong(song.id);
                                    },
                                  )
                                : StreamBuilder<MediaItem?>(
                                    stream: songHandler.mediaItem,
                                    builder: (context, snapshot) {
                                      final playingItem = snapshot.data;
                                      final bool isCurrentSong =
                                          playingItem != null && playingItem.id == song.id;

                                      if (isCurrentSong) {
                                        return SizedBox(
                                          width: 30.w,
                                          child: StreamBuilder<PlaybackState>(
                                            stream: songHandler.playbackState,
                                            builder: (context, playbackSnapshot) {
                                              final isPlaying = playbackSnapshot.data?.playing ?? false;
                                              return MiniMusicVisualizer(
                                                color: Theme.of(context).colorScheme.primary,
                                                width: 4,
                                                height: 15,
                                                radius: 2,
                                                animate: isPlaying,
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Theme.of(context).iconTheme.color?.withValues(alpha:  0.6),
                                        );
                                      }
                                    },
                                  ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            subtitle: Text(
                              song.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 10.sp,
                                overflow: TextOverflow.ellipsis,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor.withValues(alpha:  0.3),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: QueryArtworkWidget(
                                  id: int.tryParse(song.displayDescription ?? "0") ?? 0,
                                  keepOldArtwork: true,
                                  type: ArtworkType.AUDIO,
                                  artworkWidth: 50,
                                  artworkHeight: 50,
                                  artworkFit: BoxFit.cover,
                                  artworkQuality: FilterQuality.low,
                                  nullArtworkWidget: Icon(
                                    Icons.music_note,
                                    color: Theme.of(context).iconTheme.color?.withValues(alpha:  0.6),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () async {
                              if (playlistcontroller.isSelectionMode.value) {
                                playlistcontroller.selectSong(song.id);
                                return;
                              }

                              if (controller.isallmusic.isFalse) {
                                await controller.handleAllSongs();
                              }

                              await songHandler.skipToQueueItem(index);

                              controller.isallmusic.value = true;
                              controller.isplaylist.value = false;
                              controller.isfavorite.value = false;
                              controller.issearch.value = false;

                              await box.putAll({
                                "isallmusic": controller.isallmusic.value,
                                "isplaylist": controller.isplaylist.value,
                                "isfavorite": controller.isfavorite.value,
                              });

                              navigator.changepage(2);
                              await songHandler.play();
                            },
                            onLongPress: () {
                              playlistcontroller.toggleSelectionMode();
                              playlistcontroller.selectSong(song.id);
                            },
                          ),
                        );
                      }),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}