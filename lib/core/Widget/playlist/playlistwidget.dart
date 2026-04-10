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

    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            ListTile(
              leading: Icon(Icons.music_note, size: 30.w),
              title: Text(
                "A L L  M U S I C",
                style: TextStyle(fontSize: 20.sp),
              ),
              onTap: () {
                navigatorcontroller.changepage(0);
              },
            ),
            SizedBox(height: 10.h),
            ListTile(
              leading: Icon(Icons.favorite, size: 30.w),
              title: Text("F A V O R I T E", style: TextStyle(fontSize: 20.sp)),
              onTap: () async {
                await playlistcontroller.loadFavorites();
                Get.toNamed(Approutes.favorite);
              },
            ),
            SizedBox(height: 20.h),
            const Divider(),
            SizedBox(height: 20.w),
            Text(
              "Y O U R   P L A Y L I S T S:",
              style: TextStyle(fontSize: 20.sp),
            ),
            Obx(() {
              if (playlistcontroller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: playlistcontroller.playlists.length,
                  itemBuilder: (BuildContext context, int index) {
                    final playlist = playlistcontroller.playlists[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Neubox(
                        borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(12),
                                icon: Icons.delete,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.inversePrimary,
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
                            leading: Icon(Icons.playlist_play),
                            title: Text(playlist.name.toUpperCase()),
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
