import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/main.dart';

import 'package:transparent_image/transparent_image.dart';

class Playlistpage extends StatelessWidget {
  const Playlistpage({super.key});

  @override
  Widget build(BuildContext context) {
    Playlistcontroller playlistcontroller = Get.put(Playlistcontroller());
    Navigatorcontroller navigator = Get.put(Navigatorcontroller());
    return FutureBuilder<List<MediaItem>>(
      future:
          playlistcontroller.loadsongplaylist(playlistcontroller.playlistId),
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
            body: ListView.builder(
              itemCount: audio.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(7),
                  child: Neubox(
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(
                        audio[index].title,
                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                      subtitle: Text(audio[index].artist!,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis)),
                      leading: audio[index].artUri == null
                          ? const Icon(
                              Icons.music_note,
                            )
                          : FadeInImage(
                              height: 45,
                              width: 45,
                              filterQuality: FilterQuality.high,
                              image:
                                  FileImage(File.fromUri(audio[index].artUri!)),
                              placeholder: MemoryImage(kTransparentImage),
                              fit: BoxFit.cover,
                            ),
                      onTap: () async {
                        await playlistcontroller.handelplaylists();
                        songHandler.skipToQueueItem(index);
                        Get.back();
                        navigator.changepage(2);
                      },
                    ),
                  ),
                );
              },
            ));
      },
    );
  }
}
