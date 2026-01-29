import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/Widget/listsongwidget.dart';
import 'package:musiclotm/core/Widget/showdialog.dart';

class Allmusicscreen extends StatelessWidget {
  const Allmusicscreen({super.key});

  @override
  Widget build(BuildContext context) {
    AnimationControllerX animationControllerX = Get.find();
    Playlistcontroller playlistcontroller = Get.find();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GetBuilder<AnimationControllerX>(
        init: animationControllerX,
        builder: (controller) {
          return playlistcontroller.selectionMode == true
              ? FloatingActionBubble(
                  items: <Bubble>[
                    Bubble(
                      title: "Add to playlists",
                      iconColor: Colors.black,
                      bubbleColor: Theme.of(context).colorScheme.secondary,
                      icon: Icons.playlist_add,
                      titleStyle: TextStyle(
                        fontSize: 8.sp, // Added: Responsive font size
                        color: Colors.white, // Added: Explicit text color
                      ),
                      onPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomAlertDialog(
                            onPressed: () {
                              playlistcontroller.addSongsToSelectedPlaylists();
                              Get.back();
                              controller
                                  .reverseAnimation(); // Fixed: Use proper method
                              playlistcontroller.toggleSelection();
                            },
                          ),
                        );
                      },
                    ),
                    Bubble(
                      title: "Select all",
                      iconColor: Colors.black,
                      bubbleColor: Theme.of(context).colorScheme.secondary,
                      icon: Icons.select_all,
                      titleStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                      onPress: () {
                        // Select all songs
                        for (var song
                            in playlistcontroller.selectedSongTitles) {
                          playlistcontroller.onSongSelected(true, song);
                        }
                        controller
                            .reverseAnimation(); // Fixed: Use proper method
                      },
                    ),
                    Bubble(
                      title: "Cancel",
                      iconColor: Colors.black,
                      bubbleColor: Theme.of(context).colorScheme.secondary,
                      icon: Icons.close,
                      titleStyle: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.white,
                      ),
                      onPress: () {
                        playlistcontroller.clearSongSelection();
                        controller
                            .reverseAnimation(); // Fixed: Use proper method
                        playlistcontroller.toggleSelection();
                      },
                    ),
                  ],
                  animatedIconData: AnimatedIcons.menu_arrow,
                  animation:
                      controller.animation, // Fixed: Use the correct animation
                  onPress: controller.toggleAnimation,
                  backGroundColor: Theme.of(context).colorScheme.secondary,
                  iconColor: Theme.of(context).colorScheme.inversePrimary,
                )
              : const SizedBox.shrink();
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "A L L  M U S I C",
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context)
                .colorScheme
                .primary, // Added: Theme-aware color
          ),
        ),
        centerTitle: true,
        elevation: 0, // Added: Remove shadow for cleaner look
      ),
      body: Songlistwidget(),
    );
  }
}
