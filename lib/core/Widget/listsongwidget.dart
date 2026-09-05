import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/song_options_sheet.dart';
import 'package:musiclotm/core/Widget/unified_song_tile.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Songlistwidget extends StatelessWidget {
  const Songlistwidget({super.key});

  @override
  Widget build(BuildContext context) { 
    final navigator = Get.find<Navigatorcontroller>();
    final songscontroller = Get.find<Songscontroller>();
    final playlistcontroller = Get.find<Playlistcontroller>();
    final songHandler = Get.find<SongHandler>();
    final box = Hive.box('music');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selection mode header - minimal rebuild scope
          Obx(() {
            if (playlistcontroller.isSelectionMode.value) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selection Mode',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${playlistcontroller.selectedSongIds.length} song${playlistcontroller.selectedSongIds.length == 1 ? '' : 's'} selected',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Header with song count and sort dropdown
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 16.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Obx(
                      () => Text(
                        "${songscontroller.songs.length} Songs",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Theme.of(context).colorScheme.onPrimary,
                        icon: Icon(
                          Icons.sort,
                          size: 20.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        value: songscontroller.sortTypeAllMusic.value,
                        onChanged: (String? newValue) async {
                          if (newValue == null) return;
                          songscontroller.updateSortType(newValue);
                          log('Sort type changed to: $newValue');
                        },
                        items:
                            [
                              DropdownMenuItem(
                                value: "titleASC",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha,
                                      size: 16.sp,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "A → Z",
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "titleDESC",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha,
                                      size: 16.sp,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Z → A",
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "dateASC",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16.sp,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Oldest",
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "dateDESC",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16.sp,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "Newest",
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ].map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item.value,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  child: item.child,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Theme.of(context).dividerColor,
            height: 1,
            thickness: 0.5,
          ),

          SizedBox(height: 12.h),

          // Song List - CRITICAL OPTIMIZATION: Outer Obx ONLY depends on loading state & song list
          Expanded(
            child: Obx(() {
              if (songscontroller.isLoading.value) {
                return _buildLoadingIndicator(context);
              }

              final audio = songscontroller.songs;

              if (audio.isEmpty) {
                return _buildEmptyState(context, songscontroller);
              }

              return ScrollablePositionedList.builder(
                itemScrollController: songscontroller.itemScrollController,
                itemCount: audio.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 80.h),
                itemBuilder: (BuildContext context, int index) {
                  final song = audio[index];

                  // ✅ SINGLE Obx per item - minimal rebuild scope
                  // Only rebuilds when: current song changes OR selection state changes for THIS item
                  return Obx(() {
                    final currentMediaItem =
                        songscontroller.currentMediaItem.value;
                    final isPlaying = currentMediaItem?.id == song.id;
                    final isSelectionMode =
                        playlistcontroller.isSelectionMode.value;
                    final isSelected = playlistcontroller.selectedSongIds
                        .contains(song.id);

                    return _buildSongItem(
                      context,
                      song,
                      index,
                      isPlaying,
                      isSelectionMode,
                      isSelected,
                      songscontroller,
                      playlistcontroller,
                      songHandler,
                      box,
                      navigator,
                      ValueKey(song.id), // Critical for list performance
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.sp,
            height: 40.sp,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading songs...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Songscontroller songscontroller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off_rounded,
            size: 60.sp,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No songs found',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add music to your device or check permissions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              songscontroller.checkPermissionAndLoad();
            },
            icon: Icon(Icons.refresh, size: 16.sp),
            label: Text('Refresh Library', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(
    BuildContext context,
    MediaItem song,
    int index,
    bool isPlaying,
    bool isSelectionMode,
    bool isSelected,
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
    Key key,
  ) {
    return UnifiedSongTile(
      key: key,
      song: song,
      isPlaying: isPlaying,
      isSelectionMode: isSelectionMode,
      isSelected: isSelected,
      onTap: () async {
        if (isSelectionMode) {
          playlistcontroller.selectSong(song.id);
          return;
        }
        await _playSong(
          songscontroller,
          playlistcontroller,
          songHandler,
          box,
          navigator,
          song,
          index,
        );
      },
      onLongPress: () {
        if (!isSelectionMode) {
          playlistcontroller.toggleSelectionMode();
        }
        playlistcontroller.selectSong(song.id);
      },
      onSelectChanged: (_) => playlistcontroller.selectSong(song.id),
      onMoreOptions: () {
        SongOptionsSheet.show(
          context: context,
          song: song,
          onDelete: () async {
            await playlistcontroller.deleteSong(song.id);
          },
        );
      },
    );
  }

  Future<void> _playSong(
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
    MediaItem song,
    int index,
  ) async {
    try {
      // If not in all music view, switch to it
      if (!songscontroller.isallmusic.value) {
        await songscontroller.handleAllSongs();
      }

      // Skip to the selected song
      await songHandler.skipToQueueItem(index);

      // Update view states
      songscontroller.isallmusic.value = true;
      songscontroller.isplaylist.value = false;
      songscontroller.isfavorite.value = false;

      // Save view state
      await box.putAll({
        "isallmusic": true,
        "isplaylist": false,
        "isfavorite": false,
      });

      // Start playing
      await songHandler.play();

      log('Playing song: ${song.title} at index: $index');
    } catch (e) {
      log('Error playing song: $e');
      Get.snackbar(
        'Error',
        'Failed to play song: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
