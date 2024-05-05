import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/core/Widget/neubox.dart';

import 'package:transparent_image/transparent_image.dart';

class Songlistwidget extends StatelessWidget {
  const Songlistwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(Songscontroller());
    return GetBuilder<Songscontroller>(
        builder: (controller) => Padding(
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
                        "songs : ${controller.songs.length}",
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
                      itemCount: controller.songs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.h, horizontal: 10.w),
                          child: Neubox(
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(
                                controller.songs[index].title,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                              ),
                              subtitle: Text(
                                  "${controller.songs[index].artist}",
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis)),
                              leading: controller.songs[index].artUri == null
                                  ? const Icon(
                                      Icons.music_note,
                                    )
                                  : FadeInImage(
                                      height: 45,
                                      width: 45,
                                      // Use FileImage for the FadeInImage widget
                                      image: FileImage(File.fromUri(
                                          controller.songs[index].artUri!)),
                                      placeholder:
                                          MemoryImage(kTransparentImage),

                                      fit: BoxFit.cover,
                                    ),
                              onTap: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ));
  }
}
