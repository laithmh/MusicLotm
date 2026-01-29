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
    // Playlistcontroller playlistcontroller = Get.find();

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
                  value: songscontroller.sortypeallMusic ??
                      'titleASC', // Added: Default value
                  onChanged: (String? newValue) async {
                    if (newValue == null) return; // Added: Null check

                    sort(song: songscontroller.songs, sortType: newValue);
                    sortSongModel(
                        song: songscontroller.songModels, sortType: newValue);
                    songscontroller.sortypeallMusic =
                        newValue; // Updated: Set the sort type
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
                        style: TextStyle(
                            fontSize: 10.sp), // Added: Responsive text size
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
            // Changed: Use Expanded instead of fixed height for better responsiveness
            child: GetX<Songscontroller>(
              builder: (controller) {
                List<MediaItem> audio = controller.songs;

                if (audio.isEmpty) {
                  // Added: Empty state handling
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
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 4.h, horizontal: 5.w), // Reduced padding
                      child: GetBuilder<Playlistcontroller>(
                        builder: (pcontroller) {
                          SongModel? selectedSong =
                              controller.songModels.firstWhere(
                            (element) =>
                                element.displayNameWOExt == audio[index].title,
                            // orElse: () => SongModel(
                            // ),
                          );

                          return Neubox(
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              trailing: pcontroller.selectionMode
                                  ? Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.blueGrey,
                                      value: pcontroller.selectedSongTitles
                                          .contains(
                                              selectedSong.displayNameWOExt),
                                      onChanged: (selected) {
                                        pcontroller.onSongSelected(selected,
                                            selectedSong.displayNameWOExt);
                                      },
                                    )
                                  : StreamBuilder<MediaItem?>(
                                      stream: songHandler
                                          .mediaItem, // Listen to the global song stream
                                      builder: (context, snapshot) {
                                        final playingItem = snapshot.data;
                                        // Compare IDs to see if this specific tile is the one playing
                                        final bool isCurrentSong =
                                            playingItem != null &&
                                                playingItem.id ==
                                                    audio[index].id;

                                        if (isCurrentSong) {
                                          return SizedBox(
                                            width: 30
                                                .w, // Constraints the width so it doesn't "consume" the tile
                                            child: StreamBuilder<PlaybackState>(
                                              stream: songHandler
                                                  .playbackState, // Listen for play/pause changes
                                              builder:
                                                  (context, playbackSnapshot) {
                                                final isPlaying =
                                                    playbackSnapshot
                                                            .data?.playing ??
                                                        false;
                                                return MiniMusicVisualizer(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 4,
                                                  height: 15,
                                                  radius: 2,
                                                  animate:
                                                      isPlaying, // Bars move only if music is active
                                                );
                                              },
                                            ),
                                          );
                                        } else {
                                          // Standard icon for non-playing songs
                                          return Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color
                                                ?.withValues(alpha: 0.6),
                                          );
                                        }
                                      },
                                    ),
                              title: Text(
                                audio[index].title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              subtitle: Text(
                                audio[index].artist ?? 'Unknown Artist',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  overflow: TextOverflow.ellipsis,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              leading: Container(
                                // Added: Container for consistent sizing
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .cardColor
                                      .withValues(alpha: 0.3),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: QueryArtworkWidget(
                                    id: int.tryParse(
                                          audio[index].displayDescription ??
                                              "0",
                                        ) ??
                                        0,
                                    keepOldArtwork: true,
                                    type: ArtworkType.AUDIO,
                                    artworkWidth: 50,
                                    artworkHeight: 50,
                                    artworkFit: BoxFit.cover,
                                    artworkQuality: FilterQuality
                                        .low, // Reduced quality for performance
                                    nullArtworkWidget: Icon(
                                      Icons.music_note,
                                      color: Theme.of(context)
                                          .iconTheme
                                          .color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () async {
                                if (controller.isallmusic.isFalse) {
                                  await controller.handleAllSongs();
                                }

                                await songHandler.skipToQueueItem(index);

                                // Update controller states
                                controller.isallmusic.value = true;
                                controller.isplaylist.value = false;
                                controller.isfavorite.value = false;
                                controller.issearch.value = false;

                                // Update persistent storage
                                await box.putAll({
                                  "isallmusic": controller.isallmusic.value,
                                  "isplaylist": controller.isplaylist.value,
                                  "isfavorite": controller.isfavorite.value,
                                });

                                navigator.changepage(2);
                                await songHandler.play();
                              },
                              onLongPress: () {
                                pcontroller.toggleSelection();
                                pcontroller.clearPlaylistSelection();
                                pcontroller.clearSongSelection();
                              },
                            ),
                          );
                        },
                      ),
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
