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
              height: 800.h,
              child: Column(
                children: [
                  TextField(
                    controller: playlistcontroller.controller,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "add new playlist"),
                    onTapOutside: (event) {
                      SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersiveSticky);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          playlistcontroller.createNewPlaylist();

                          playlistcontroller.controller.clear();
                          Get.back();
                        },
                        child: const Text("save"),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("cancel"),
                      )
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
