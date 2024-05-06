import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/controller/searchcontroller.dart';

import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/main.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    Searchcontroller searchcontroller = Get.put(Searchcontroller());
    Songscontroller songscontroller = Get.put(Songscontroller());
    Navigatorcontroller navigator = Get.put(Navigatorcontroller());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextField(
                  controller: searchcontroller.controller,
                  onChanged: (value) {
                    searchcontroller
                        .filterData(searchcontroller.controller.text);
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "search"),
                  onTapOutside: (event) {
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky);
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
                              onTap: () {
                                songscontroller.findCurrentSongPlayingIndex(
                                    controller.filteredData[index].id);
                                songHandler.skipToQueueItem(songscontroller
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
