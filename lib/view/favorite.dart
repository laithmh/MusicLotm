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
import 'package:musiclotm/main.dart';

import 'package:on_audio_query/on_audio_query.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    final songscontroller = Get.find<Songscontroller>();
    final playlistcontroller = Get.find<Playlistcontroller>();
    final navigator = Get.find<Navigatorcontroller>();

    List<String> dropdownItems = [
      'titleASC',
      'titleDESC',
      'dateASC',
      'dateDESC',
    ];

    return Scaffold(
      bottomNavigationBar: const Navigationbarwidget(),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: const Icon(Icons.sort),
                value: songscontroller.sortypeFavorite ?? 'titleASC',
                onChanged: (String? newValue) async {
                  if (newValue == null) return;

                  songscontroller.sortypeFavorite = newValue;
                  await box.put("sortTypeFavorite", newValue);

                  // Reload favorites with new sorting
                  await playlistcontroller.loadFavorites();
                  songscontroller.update();
                },
                items: dropdownItems.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 10.sp)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "F A V O R I T E S",
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (playlistcontroller.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 60.w,
                  color: Theme.of(context).disabledColor,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Tap the heart icon on any song to add it here',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: playlistcontroller.favorites.length,
          itemBuilder: (BuildContext context, int index) {
            final song = playlistcontroller.favorites[index];
            return Padding(
              key: ValueKey(song.id),
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
              child: Neubox(
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  trailing: StreamBuilder<MediaItem?>(
                    stream: songHandler.mediaItem,
                    builder: (context, snapshot) {
                      final playingItem = snapshot.data;
                      final bool isCurrentSong =
                          playingItem != null && playingItem.id == song.id;

                      if (isCurrentSong) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MiniMusicVisualizer(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              width: 4,
                              height: 15,
                              radius: 2,
                              animate: songHandler.playbackState.value.playing,
                            ),
                            SizedBox(width: 10.w),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20.w,
                              ),
                              onPressed: () {
                                playlistcontroller.toggleFavorite(song);
                              },
                            ),
                          ],
                        );
                      }
                      return IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20.w,
                        ),
                        onPressed: () {
                          playlistcontroller.toggleFavorite(song);
                        },
                      );
                    },
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Text(
                    song.artist ?? 'Unknown Artist',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  leading: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor.withValues(alpha:  0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: QueryArtworkWidget(
                        id:
                            int.tryParse(song.id) ??
                            0, // Use song.id instead of displayDescription
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Icon(
                          Icons.music_note,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    // Update controller states
                    songscontroller.isallmusic.value = false;
                    songscontroller.isplaylist.value = false;
                    songscontroller.isfavorite.value = true;

                    await box.putAll({
                      "isallmusic": songscontroller.isallmusic.value,
                      "isplaylist": songscontroller.isplaylist.value,
                      "isfavorite": songscontroller.isfavorite.value,
                    });

                    // Load and play favorites
                    await playlistcontroller.handleFavorites();
                    await songHandler.skipToQueueItem(index);

                    // Navigate to player screen
                    navigator.changepage(2);
                    await songHandler.play();
                  },
                  onLongPress: () {
                    // Optionally add to playlist selection mode
                    Get.snackbar(
                      'Quick Action',
                      'Long press on song list to add to playlists',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
