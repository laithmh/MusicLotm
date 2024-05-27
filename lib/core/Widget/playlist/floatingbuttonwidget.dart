import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

class Floatingbuttonwidget extends StatelessWidget {
  const Floatingbuttonwidget({super.key});

  @override
  Widget build(BuildContext context) {
    Playlistcontroller playlistcontroller = Get.put(Playlistcontroller());

    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: SizedBox(
              height: 700.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextFormField(
                      controller: playlistcontroller.controller,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "add new playlist"),
                      onTapOutside: (event) {
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.immersiveSticky);
                      },
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          Get.back();
                        },
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text("cancel"),
                      ),
                      MaterialButton(
                        onPressed: () {
                          if (playlistcontroller.controller.text
                              .trim()
                              .isNotEmpty) {
                            playlistcontroller.createNewPlaylist();

                            playlistcontroller.controller.clear();
                            Get.back();
                          } else {
                            Get.snackbar("", "the playlist name is empty");
                          }
                        },
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text("save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}
