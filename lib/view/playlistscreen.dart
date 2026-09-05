import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/song_options_sheet.dart';
import 'package:musiclotm/core/Widget/unified_song_tile.dart';

class Playlistpage extends StatefulWidget {
  const Playlistpage({super.key});

  @override
  State<Playlistpage> createState() => _PlaylistpageState();
}

class _PlaylistpageState extends State<Playlistpage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlaylist();
    });
  }

  void _loadPlaylist() async {
    final playlistcontroller = Get.find<Playlistcontroller>();
    if (playlistcontroller.currentPlaylistId.value.isNotEmpty) {
      await playlistcontroller.loadPlaylistSongs(
        playlistcontroller.currentPlaylistId.value,
        restoreState: true,
      );
    }
  }

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
        title: Obx(() {
          final playlist = playlistcontroller.playlists.firstWhereOrNull(
            (p) => p.id == playlistcontroller.currentPlaylistId.value,
          );
          return Text(
            playlist?.name ?? 'Playlist',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          );
        }),
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
                  value: playlistcontroller.sortTypePlaylists.value,
                  onChanged: (String? newValue) async {
                    if (newValue == null) return;
                    playlistcontroller.updatePlaylistSortType(newValue);
                  },
                  items: [
                    DropdownMenuItem(
                      value: "titleASC",
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_by_alpha,
                            size: 16.sp,
                            color: Theme.of(context).colorScheme.inversePrimary,
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
                            color: Theme.of(context).colorScheme.inversePrimary,
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
                            color: Theme.of(context).colorScheme.inversePrimary,
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
                            color: Theme.of(context).colorScheme.inversePrimary,
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 24.sp),
            color: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'rename') {
                final newName = await _showRenameDialog(
                  context,
                  playlistcontroller,
                );
                if (newName != null && newName.isNotEmpty) {
                  await playlistcontroller.renamePlaylist(
                    playlistId: playlistcontroller.currentPlaylistId.value,
                    newName: newName,
                  );
                }
              } else if (value == 'clear') {
                final result = await _showConfirmationDialog(
                  context,
                  title: 'Clear Playlist',
                  message: 'Remove all songs from this playlist?',
                );
                if (result == true) {
                  await playlistcontroller.clearPlaylist(
                    playlistcontroller.currentPlaylistId.value,
                  );
                }
              } else if (value == 'delete') {
                final result = await _showConfirmationDialog(
                  context,
                  title: 'Delete Playlist',
                  message: 'Are you sure? This action cannot be undone.',
                  isDestructive: true,
                );
                if (result == true) {
                  await playlistcontroller.deletePlaylist(
                    playlistcontroller.currentPlaylistId.value,
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Rename',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.clear_all,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20.sp, color: Colors.red),
                      SizedBox(width: 12.w),
                      Text(
                        'Delete',
                        style: TextStyle(fontSize: 13.sp, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.onPrimary,
        child: _buildPlaylistContent(
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

  Widget _buildPlaylistContent(
    BuildContext context,
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
  ) {
    // ✅ CRITICAL: Single Obx for structural state ONLY (loading + song list)
    // ❌ NO dependency on currentMediaItem → prevents full list rebuild on playback
    return Obx(() {
      if (playlistcontroller.isLoading.value) {
        return _buildLoadingIndicator(context);
      }

      final songs = playlistcontroller.currentPlaylistSongs;

      if (songs.isEmpty) {
        return _buildEmptyState(context, navigator);
      }

      return ReorderableListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        physics: const BouncingScrollPhysics(),
        onReorderItem: (oldIndex, newIndex) async {
          await playlistcontroller.reorderPlaylistSongs(oldIndex, newIndex);
        },
        itemCount: songs.length,
        // ✅ CRITICAL: Stable widget identity for ReorderableListView + Slidable
        // Wrapping entire item in Obx BREAKS drag/swipe animations
        itemBuilder: (BuildContext context, int index) {
          final song = songs[index];

          return _buildPlaylistItem(
            context,
            song,
            index,
            songscontroller,
            playlistcontroller,
            songHandler,
            box,
            navigator,
            Key(
              'playlist-${playlistcontroller.currentPlaylistId.value}-${song.id}-$index',
            ),
          );
          // ✅ Stable key format required by ReorderableListView
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
                Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading playlist...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.inversePrimary,
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
            Icons.playlist_add_rounded,
            size: 80.sp,
            color: Theme.of(context).colorScheme.surface,
          ),
          SizedBox(height: 20.h),
          Text(
            'Playlist is empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Add songs from the All Music tab to this playlist',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () {
              navigator.changepage(0); // Navigate to all songs
            },
            icon: Icon(Icons.add, size: 18.sp),
            label: Text('Add Songs', style: TextStyle(fontSize: 14.sp)),
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

  Widget _buildPlaylistItem(
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
      padding: EdgeInsets.only(bottom: 6.h),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                final result = await _showConfirmationDialog(
                  context,
                  title: 'Remove Song',
                  message: 'Remove this song from the playlist?',
                );
                if (result == true) {
                  await playlistcontroller.removeSongFromPlaylist(
                    playlistId: playlistcontroller.currentPlaylistId.value,
                    songId: song.id,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              icon: Icons.delete,
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ],
        ),
        child: Obx(() {
          final isPlaying =
              songscontroller.currentMediaItem.value?.id == song.id;

          return UnifiedSongTile(
            song: song,
            isPlaying: isPlaying,
            onTap: () async {
              await _playPlaylistSong(
                songscontroller,
                playlistcontroller,
                songHandler,
                box,
                navigator,
                song,
                index,
              );
            },
            onMoreOptions: () {
              SongOptionsSheet.show(
                context: context,
                song: song,
                onDelete: () async {
                  await playlistcontroller.removeSongFromPlaylist(
                    playlistId: playlistcontroller.currentPlaylistId.value,
                    songId: song.id,
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }

  Future<void> _playPlaylistSong(
    Songscontroller songscontroller,
    Playlistcontroller playlistcontroller,
    SongHandler songHandler,
    Box box,
    Navigatorcontroller navigator,
    MediaItem song,
    int index,
  ) async {
    try {
      await playlistcontroller.handlePlaylist(
        playlistcontroller.currentPlaylistId.value,
        restoreState: false,
        initialIndex: index,
      );

      // Update view states
      songscontroller.isallmusic.value = false;
      songscontroller.isplaylist.value = true;
      songscontroller.isfavorite.value = false;

      // Save view state
      await box.putAll({
        "isallmusic": false,
        "isplaylist": true,
        "isfavorite": false,
      });

      log('Playing playlist song: ${song.title} at index: $index');
    } catch (e) {
      log('Error playing playlist song: $e');
      Get.snackbar(
        'Error',
        'Failed to play song: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> _showRenameDialog(
    BuildContext context,
    Playlistcontroller controller,
  ) async {
    final playlist = controller.playlists.firstWhereOrNull(
      (p) => p.id == controller.currentPlaylistId.value,
    );

    final nameController = TextEditingController(text: playlist?.name ?? '');

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rename Playlist',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Playlist Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Get.back(result: nameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              isDestructive ? 'Delete' : 'Confirm',
              style: TextStyle(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
