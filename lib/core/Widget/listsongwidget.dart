import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';

import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/main.dart';

import 'package:transparent_image/transparent_image.dart';

class Songlistwidget extends StatelessWidget {
  const Songlistwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Navigatorcontroller navigator = Get.find();
    Songscontroller controller = Get.find();
    return StreamBuilder<RxList<MediaItem>>(
      stream: controller.myStream,
      initialData: <MediaItem>[].obs,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        RxList<MediaItem> music = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.w,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "songs : ${music.length}",
                      style: TextStyle(fontSize: 45.sp),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                  ],
                ),
                const Divider(),
                SizedBox(
                  height: 10.w,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: music.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.h, horizontal: 10.w),
                        child: Neubox(
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            title: Text(
                              music[index].title,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                            subtitle: Text("${music[index].artist}",
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis)),
                            leading: music[index].artUri == null
                                ? const Icon(
                                    Icons.music_note,
                                  )
                                : FadeInImage(
                                    height: 45,
                                    width: 45,
                                    filterQuality: FilterQuality.high,
                                    image: FileImage(
                                        File.fromUri(music[index].artUri!)),
                                    placeholder: MemoryImage(kTransparentImage),
                                    fit: BoxFit.cover,
                                  ),
                            onTap: () async {
                              await controller.handelallsongs();
                              await songHandler.skipToQueueItem(index);
                              navigator.changepage(2);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
