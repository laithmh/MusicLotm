import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/function/findcurrentIndex.dart';
import 'package:musiclotm/main.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    Searchcontroller searchcontroller = Get.find();
    Songscontroller songscontroller = Get.find();
    Navigatorcontroller navigator = Get.find();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 120.h, horizontal: 70.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: searchcontroller.controller,
                  onChanged: (value) {
                    searchcontroller
                        .filterData(searchcontroller.controller.text);
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "search"),
                  onTapOutside: (event) {
                    searchcontroller.controller.clear();
                  }),
            ),
            Expanded(
                flex: 2,
                child: GetBuilder<Searchcontroller>(
                  builder: (controller) {
                    return ListView.builder(
                      itemCount: controller.filteredData.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(7),
                          child: Neubox(
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(controller.filteredData[index].title),
                              subtitle:
                                  Text(controller.filteredData[index].artist!),
                              leading: const Icon(Icons.music_note),
                              onTap: () async {
                                songscontroller.isallmusic.value = true;
                                songscontroller.isplaylist.value = false;
                                songscontroller.isfavorite.value = false;

                                findCurrentSongPlayingIndex(
                                    controller.filteredData[index].id);
                                await songscontroller.handelallsongs();
                                await songHandler.skipToQueueItem(
                                    songscontroller
                                        .currentSongPlayingIndex.value);
                                navigator.changepage(2);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}
