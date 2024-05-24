import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/main.dart';
import 'package:transparent_image/transparent_image.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    Songscontroller songscontroller = Get.find();
    Playlistcontroller playlistcontroller = Get.find();
    Navigatorcontroller navigator = Get.find();

    return Scaffold(
      bottomNavigationBar: const Navigationbarwidget(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "F A V O R I T E",
          style: TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<RxList<MediaItem>>(
        future: playlistcontroller.loadefavorites(),
        initialData: const <MediaItem>[].obs,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<MediaItem> audio = snapshot.data;
          return ListView.builder(
            itemCount: audio.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                key: Key(audio[index].id),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                child: Neubox(
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    title: Text(
                      audio[index].title,
                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    subtitle: Text(audio[index].artist!),
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
                      if (songscontroller.isfavorite.isFalse) {
                        await playlistcontroller.handelfavorite();
                      }
                      songHandler.skipToQueueItem(index);
                      songscontroller.isallmusic.value = false;
                      songscontroller.isplaylist.value = false;
                      songscontroller.isfavorite.value = true;
                      box.putAll({
                        "isallmusic": songscontroller.isallmusic.value,
                        "isplaylist": songscontroller.isplaylist.value,
                        "isfavorite": songscontroller.isfavorite.value,
                      });
                      Get.back();
                      navigator.changepage(2);
                      await songHandler.play();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
