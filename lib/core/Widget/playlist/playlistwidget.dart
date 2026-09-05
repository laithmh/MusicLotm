import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Playlistwidget extends StatelessWidget {
  const Playlistwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Navigatorcontroller navigatorcontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.onPrimary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Navigation shortcuts
            Neubox(
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Icon(Icons.music_note, size: 26.sp, color: colorScheme.primary),
                title: Text(
                  "All Music",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.inversePrimary,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: colorScheme.primary),
                onTap: () {
                  navigatorcontroller.changepage(0);
                },
              ),
            ),
            SizedBox(height: 10.h),
            Neubox(
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Icon(Icons.favorite, size: 26.sp, color: Colors.redAccent),
                title: Text(
                  "Favorites",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.inversePrimary,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: colorScheme.primary),
                onTap: () async {
                  await playlistcontroller.loadFavorites();
                  Get.toNamed(Approutes.favorite);
                },
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Your Playlists",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (playlistcontroller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                );
              }

              if (playlistcontroller.playlists.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.queue_music,
                          size: 54.sp,
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No playlists yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.inversePrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Tap + to create your first playlist',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: playlistcontroller.playlists.length,
                  itemBuilder: (BuildContext context, int index) {
                    final playlist = playlistcontroller.playlists[index];
                    final songCount = playlist.songIds.length;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Neubox(
                        borderRadius: BorderRadius.circular(16),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  await playlistcontroller.deletePlaylist(
                                    playlist.id,
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                icon: Icons.delete,
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Colors.white,
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () async {
                              await playlistcontroller.loadPlaylistSongs(
                                playlist.id,
                              );
                              playlistcontroller.currentPlaylistId.value =
                                  playlist.id;
                              Get.toNamed(Approutes.playlistscreen);
                            },
                            leading: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.playlist_play,
                                size: 26.sp,
                                color: colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              playlist.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inversePrimary,
                              ),
                            ),
                            subtitle: Text(
                              '$songCount ${songCount == 1 ? 'song' : 'songs'}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: colorScheme.primary,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
