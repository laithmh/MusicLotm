import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    final songscontroller = Get.find<Songscontroller>();
    final playlistcontroller = Get.find<Playlistcontroller>();
    final navigator = Get.find<Navigatorcontroller>();
    final songHandler = Get.find<SongHandler>();
    final box = Hive.box('music');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Favorites",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12.w),
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
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  value: playlistcontroller.sortTypeFavorites.value,
                  onChanged: (String? newValue) async {
                    if (newValue == null) return;
                    playlistcontroller.updateFavoriteSortType(newValue);
                    songscontroller.update();
                  },
                  items: [
                    DropdownMenuItem(
                      value: "titleASC",
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_by_alpha,
                            size: 16.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 8.w),
                          Text("A → Z", style: TextStyle(fontSize: 12.sp)),
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 8.w),
                          Text("Z → A", style: TextStyle(fontSize: 12.sp)),
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 8.w),
                          Text("Oldest", style: TextStyle(fontSize: 12.sp)),
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 8.w),
                          Text("Newest", style: TextStyle(fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: _buildFavoritesContent(
          context,
          songscontroller,
          playlistcontroller,
          songHandler,
          box,
          navigator,
        ),
      ),
      bottomNavigationBar: const Navigationbarwidget(),
    );
  }

  Widget _buildFavoritesContent(
    BuildContext context,
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
  ) {
    // ✅ CRITICAL: Separate loading state Obx (minimal rebuild scope)
    return Obx(() {
      if (playlistcontroller.isLoading.value) {
        return _buildLoadingIndicator(context);
      }

      final favorites = playlistcontroller.favorites;

      if (favorites.isEmpty) {
        return _buildEmptyState(context, navigator);
      }

      // ✅ SINGLE Obx for list structure ONLY (isLoading + favorites list)
      // ❌ NO dependency on currentMediaItem here → prevents full list rebuild on playback changes
      return ReorderableListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        physics: const BouncingScrollPhysics(),
        itemCount: favorites.length,
        onReorder: (oldIndex, newIndex) async {
          if (oldIndex < newIndex) newIndex -= 1;
          await playlistcontroller.reorderFavorites(oldIndex, newIndex);
        },
        // ✅ CRITICAL: ReorderableListView requires stable widget identity
        // Wrapping entire item in Obx BREAKS reordering animations → isolate ONLY the playing indicator
        itemBuilder: (BuildContext context, int index) {
          final song = favorites[index];

          return _buildFavoriteItem(
            context,
            song,
            index,
            songscontroller,
            playlistcontroller,
            songHandler,
            box,
            navigator,
            Key('favorite-item-${song.id}'), // Stable key based on song ID
          );
        },
      );
    });
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
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading favorites...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Navigatorcontroller navigator) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80.sp,
            color: Theme.of(context).colorScheme.surface,
          ),
          SizedBox(height: 20.h),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Tap the heart icon on any song to add it to your favorites',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () {
              navigator.changepage(0); // Navigate to all songs
            },
            icon: Icon(Icons.music_note, size: 18.sp),
            label: Text('Browse Songs', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    MediaItem song,
    int index,
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
    Key key,
  ) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: () async {
          await _playFavoriteSong(
            songscontroller,
            playlistcontroller,
            songHandler,
            box,
            navigator,
            song,
            index,
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: Neubox(
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              leading: _buildArtwork(song, context),
              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                song.artist ?? 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              trailing: SizedBox(
                width: 60.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ✅ ISOLATED Obx: ONLY rebuilds the visualizer when playing state changes
                    // Prevents entire list item rebuild → maintains reorder animations
                    Obx(() {
                      final isPlaying =
                          songscontroller.currentMediaItem.value?.id == song.id;
                      return isPlaying
                          ? _buildPlayingIndicator(context, songHandler)
                          : _buildPlayButton(context);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayingIndicator(BuildContext context, SongHandler songHandler) {
    return StreamBuilder<PlaybackState>(
      stream: songHandler.playbackState,
      builder: (context, snapshot) {
        final isSongPlaying = snapshot.data?.playing ?? false;
        return SizedBox(
          width: 30.w,
          child: MiniMusicVisualizer(
            color: isSongPlaying
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            width: 3,
            height: 18,
            radius: 1.5,
            animate: isSongPlaying,
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        size: 14.sp,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  Widget _buildArtwork(MediaItem song, BuildContext context) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ), // Fixed: .withValues(alpha:) is invalid
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: QueryArtworkWidget(
          id: int.tryParse(song.extras?['song_id']?.toString() ?? "0") ?? 0,
          keepOldArtwork: true,
          type: ArtworkType.AUDIO,
          artworkWidth: 52.w,
          artworkHeight: 52.h,
          artworkFit: BoxFit.cover,
          artworkQuality: FilterQuality.medium,
          nullArtworkWidget: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 24.sp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _playFavoriteSong(
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
    MediaItem song,
    int index,
  ) async {
    try {
      await playlistcontroller.handleFavorites(
        restoreState: false,
        showSnackbar: false,
        initialIndex: index,
      );

      // Update view states
      songscontroller.isallmusic.value = false;
      songscontroller.isplaylist.value = false;
      songscontroller.isfavorite.value = true;

      // Save view state
      await box.putAll({
        "isallmusic": false,
        "isplaylist": false,
        "isfavorite": true,
      });

      log('Playing favorite song: ${song.title} at index: $index');
    } catch (e) {
      log('Error playing favorite song: $e');
      Get.snackbar(
        'Error',
        'Failed to play song: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
