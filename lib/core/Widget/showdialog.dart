import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomAlertDialog extends StatelessWidget {
  final void Function()? onPressed;
  const CustomAlertDialog({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Playlistcontroller playlistcontroller = Get.find();

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: SizedBox(
        height: 900.h,
        width: 400.w,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: playlistcontroller.playlists.length,
                itemBuilder: (BuildContext context, index) {
                  PlaylistModel playlist = playlistcontroller.playlists[index];
                  return GetBuilder<Playlistcontroller>(
                    builder: (controller) {
                      return CheckboxListTile(
                        title: Text(playlist.playlist.toUpperCase()),
                        checkColor: Colors.white,
                        activeColor: Colors.blueGrey,
                        controlAffinity: ListTileControlAffinity.leading,
                        checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        value: controller.listplaylisid.contains(playlist.id),
                        onChanged: (selected) {
                          controller.onPlaylistSelected(selected, playlist.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  onPressed: () {
                    Get.back();
                    playlistcontroller.listplaylisid.clear();
                    playlistcontroller.listsongsid.clear();
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text("cancel"),
                ),
                MaterialButton(
                  onPressed: onPressed,
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text("save"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
