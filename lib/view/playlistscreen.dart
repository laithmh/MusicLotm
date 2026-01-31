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
import 'package:on_audio_query/on_audio_query.dart';

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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();
    Navigatorcontroller navigator = Get.find();

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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 24.w),
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
                await playlistcontroller.clearPlaylist(
                  playlistcontroller.currentPlaylistId.value,
                );
              } else if (value == 'delete') {
                await _showDeleteDialog(context, playlistcontroller);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20.w),
                      SizedBox(width: 10.w),
                      Text('Rename'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20.w),
                      SizedBox(width: 10.w),
                      Text('Clear All Songs'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20.w, color: Colors.red),
                      SizedBox(width: 10.w),
                      Text(
                        'Delete Playlist',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: const Icon(Icons.sort),
                value: songscontroller.sortypePlaylists ?? 'titleASC',
                onChanged: (String? newValue) async {
                  if (newValue == null) return;

                  songscontroller.sortypePlaylists = newValue;
                  await box.put("sortTypePlaylists", newValue);

                  // Sort the current playlist songs
                  if (playlistcontroller.currentPlaylistSongs.isNotEmpty) {
                    final sortedSongs = sort(
                      song: playlistcontroller.currentPlaylistSongs.toList(),
                      sortType: newValue,
                    );
                    playlistcontroller.currentPlaylistSongs.assignAll(
                      sortedSongs,
                    );
                  }
                },
                items: dropdownItems.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        title: Obx(() {
          final playlist = playlistcontroller.playlists.firstWhereOrNull(
            (p) => p.id == playlistcontroller.currentPlaylistId.value,
          );
          return Text(
            playlist?.name ?? 'Playlist',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontSize: 25.sp,
            ),
          );
        }),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: Obx(() {
        if (playlistcontroller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (playlistcontroller.currentPlaylistSongs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.playlist_add,
                  size: 60.w,
                  color: Theme.of(context).disabledColor,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No songs in this playlist',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Add songs from the All Music tab',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) async {
            if (oldIndex < newIndex) newIndex -= 1;
            await playlistcontroller.reorderPlaylistSongs(oldIndex, newIndex);
          },
          itemCount: playlistcontroller.currentPlaylistSongs.length,
          itemBuilder: (BuildContext context, int index) {
            final song = playlistcontroller.currentPlaylistSongs[index];
            return Padding(
              key: ValueKey(song.id),
              padding: const EdgeInsets.all(7),
              child: Neubox(
                borderRadius: BorderRadius.circular(12),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await playlistcontroller.removeSongFromPlaylist(
                            playlistId:
                                playlistcontroller.currentPlaylistId.value,
                            songId: song.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        icon: Icons.delete,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                    ],
                  ),
                  child: ListTile(
                    trailing: StreamBuilder<MediaItem?>(
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
                                final isPlaying =
                                    playbackSnapshot.data?.playing ?? false;
                                return MiniMusicVisualizer(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  width: 4,
                                  height: 15,
                                  radius: 2,
                                  animate: isPlaying,
                                );
                              },
                            ),
                          );
                        }
                        return Icon(
                          Icons.drag_handle,
                          size: 20.w,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.6),
                        );
                      },
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Text(
                      song.artist ?? 'Unknown Artist',
                      style: TextStyle(
                        fontSize: 10.sp,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    leading: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor.withOpacity(0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: QueryArtworkWidget(
                          id: int.tryParse(song.displayDescription ?? "0") ?? 0,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Icon(
                            Icons.music_note,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      await playlistcontroller.handlePlaylist(
                        playlistcontroller.currentPlaylistId.value,
                      );
                      await songHandler.skipToQueueItem(index);
                      await songHandler.play();

                      songscontroller.isallmusic.value = false;
                      songscontroller.isplaylist.value = true;
                      songscontroller.isfavorite.value = false;

                      await box.putAll({
                        "isallmusic": songscontroller.isallmusic.value,
                        "isplaylist": songscontroller.isplaylist.value,
                        "isfavorite": songscontroller.isfavorite.value,
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
      }),
    );
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
        title: Text('Rename Playlist'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Playlist Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Get.back(result: nameController.text.trim());
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Playlistcontroller controller,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Playlist'),
        content: Text(
          'Are you sure you want to delete this playlist? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      await controller.deletePlaylist(controller.currentPlaylistId.value);
      Get.back();
    }
  }
}
