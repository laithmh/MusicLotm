import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:musiclotm/controller/navigatorcontroller.dart';

import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Playlistwidget extends StatelessWidget {
  const Playlistwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Navigatorcontroller navigatorcontroller = Get.put(Navigatorcontroller());
    Playlistcontroller playlistcontroller = Get.put(Playlistcontroller());
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.music_note,
              size: 100.w,
            ),
            title: Text(
              "A L L  M U S I C",
              style: TextStyle(fontSize: 70.sp),
            ),
            onTap: () {
              navigatorcontroller.changepage(0);
            },
          ),
          SizedBox(
            height: 20.h,
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              size: 100.w,
            ),
            title: Text(
              "F A V O R I T E",
              style: TextStyle(fontSize: 70.sp),
            ),
            onTap: () {},
          ),
          SizedBox(
            height: 20.h,
          ),
          ListTile(
            leading: Icon(
              Icons.fireplace_rounded,
              size: 100.w,
            ),
            title: Text(
              "M O S T  W A T C H E D",
              style: TextStyle(fontSize: 70.sp),
            ),
            onTap: () {},
          ),
          const Divider(),
          SizedBox(
            height: 20.w,
          ),
          Text(
            "Y O U R   P L A Y L I S T :",
            style: TextStyle(fontSize: 70.sp),
          ),
          Expanded(
            child: SizedBox(
              height: 400.h,
              child: FutureBuilder(
                future: playlistcontroller.loadplaylist(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return GetBuilder<Playlistcontroller>(
                    builder: (controller) => ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: controller.playlists.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Neubox(
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              onTap: () {
                                
                                Get.toNamed(
                                  Approutes.playlistscreen,
                                );
                                controller.playlistindex = index;
                                controller.playlistId =
                                    controller.playlists[index].id;
                              },
                              leading: const Icon(Icons.playlist_play),
                              title: Text(controller.playlists[index].playlist
                                  .toUpperCase()),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  controller.deleteplaylist(
                                      index, controller.playlists[index].id);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
