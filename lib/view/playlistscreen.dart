import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/main.dart';
import 'package:transparent_image/transparent_image.dart';

class Playlistpage extends StatelessWidget {
  const Playlistpage({super.key});

  @override
  Widget build(BuildContext context) {
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();
    Navigatorcontroller navigator = Get.find();

    return haspermission.value
        ? FutureBuilder<List<MediaItem>>(
            future: playlistcontroller
                .loadsongplaylist(playlistcontroller.playlistId),
            initialData: const [],
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              List<MediaItem> audio = snapshot.data;

              return Scaffold(
                  bottomNavigationBar: const Navigationbarwidget(),
                  backgroundColor: Theme.of(context).colorScheme.background,
                  appBar: AppBar(
                    title: Text(
                      playlistcontroller
                          .playlists[playlistcontroller.playlistindex].playlist,
                      style: TextStyle(
                          letterSpacing: 5,
                          fontWeight: FontWeight.bold,
                          fontSize: 75.sp),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    centerTitle: true,
                  ),
                  body: GetBuilder<Playlistcontroller>(
                    builder: (controller) {
                      return ReorderableListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        buildDefaultDragHandles: false,
                        itemCount: audio.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            key: Key(audio[index].id),
                            padding: const EdgeInsets.all(7),
                            child: Neubox(
                              borderRadius: BorderRadius.circular(12),
                              child: Slidable(
                                endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          controller.removeSongFromPlaylist(
                                              controller.playlistId,
                                              playlistcontroller
                                                  .playlistsongs[index].id);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        icon: Icons.delete,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      )
                                    ]),
                                child: ListTile(
                                  trailing: ReorderableDragStartListener(
                                    enabled: true,
                                    index: index,
                                    child: const Icon(Icons.reorder),
                                  ),
                                  title: Text(
                                    audio[index].title,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  subtitle: Text(audio[index].artist!,
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis)),
                                  leading: audio[index].artUri == null
                                      ? const Icon(
                                          Icons.music_note,
                                        )
                                      : FadeInImage(
                                          height: 45,
                                          width: 45,
                                          filterQuality: FilterQuality.high,
                                          image: FileImage(File.fromUri(
                                              audio[index].artUri!)),
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          fit: BoxFit.cover,
                                        ),
                                  onTap: () async {
                                    if (songscontroller.isplaylist.isFalse) {
                                      await playlistcontroller
                                          .handelplaylists();
                                    }
                                    songHandler.skipToQueueItem(index);
                                    songscontroller.isallmusic.value = false;
                                    songscontroller.isplaylist.value = true;
                                    songscontroller.isfavorite.value = false;
                                    box.putAll({
                                      "isallmusic":
                                          songscontroller.isallmusic.value,
                                      "isplaylist":
                                          songscontroller.isplaylist.value,
                                      "isfavorite":
                                          songscontroller.isfavorite.value,
                                    });
                                    Get.back();
                                    navigator.changepage(2);
                                    await songHandler.play();
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          audio = controller.reOrder(newIndex, oldIndex, audio);
                          log("$oldIndex=====$newIndex");
                        },
                      );
                    },
                  ));
            },
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
