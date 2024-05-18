import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';

import 'package:musiclotm/controller/playlistcontroller.dart';

import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/main.dart';

import 'package:transparent_image/transparent_image.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: playlistcontroller.favoritelist.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            child: Neubox(
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                title: Text(
                  playlistcontroller.favoritelist[index].title,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
                subtitle: Text(playlistcontroller.favoritelist[index].artist!),
                leading: playlistcontroller.favoritelist[index].artUri == null
                    ? const Icon(
                        Icons.music_note,
                      )
                    : FadeInImage(
                        height: 45,
                        width: 45,
                        filterQuality: FilterQuality.high,
                        image: FileImage(File.fromUri(
                            playlistcontroller.favoritelist[index].artUri!)),
                        placeholder: MemoryImage(kTransparentImage),
                        fit: BoxFit.cover,
                      ),
                onTap: () async {
                  await playlistcontroller.handelfavorite();
                  songHandler.skipToQueueItem(index);
                  Get.back();
                  navigator.changepage(2);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
