import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/listsongwidget.dart';
import 'package:musiclotm/core/Widget/showdialog.dart';

class Allmusicscreen extends StatelessWidget {
  const Allmusicscreen({super.key});

  @override
  Widget build(BuildContext context) {
    AnimationControllerX animationControllerX = Get.find();
    Playlistcontroller playlistcontroller = Get.find();
    Songscontroller songscontroller = Get.find();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        return playlistcontroller.isSelectionMode.value
            ? FloatingActionBubble(
                items: <Bubble>[
                  Bubble(
                    title: "Add to playlists",

                    iconColor: Colors.black,
                    bubbleColor: Theme.of(context).colorScheme.secondary,
                    icon: Icons.playlist_add,
                    titleStyle: TextStyle(
                      fontSize: 8.sp,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPress: () {
                      if (playlistcontroller.selectedSongIds.isEmpty) {
                        Get.snackbar('Info', 'Please select songs first');
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (context) => CustomAlertDialog(
                          onPressed: () async {
                            if (playlistcontroller
                                .selectedPlaylistIds
                                .isEmpty) {
                              Get.snackbar(
                                'Info',
                                'Please select at least one playlist',
                              );
                              return;
                            }

                            await playlistcontroller
                                .addSelectedSongsToSelectedPlaylists();
                            Get.back();
                            animationControllerX.reverseAnimation();
                            playlistcontroller.toggleSelectionMode();
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
                      fontSize: 8.sp,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPress: () {
                      // Select all songs
                      for (var song in songscontroller.songs) {
                        if (!playlistcontroller.selectedSongIds.contains(
                          song.id,
                        )) {
                          playlistcontroller.selectSong(song.id);
                        }
                      }
                      animationControllerX.reverseAnimation();
                    },
                  ),
                  Bubble(
                    title: "Clear all",
                    iconColor: Colors.black,
                    bubbleColor: Theme.of(context).colorScheme.secondary,
                    icon: Icons.clear_all,
                    titleStyle: TextStyle(
                      fontSize: 8.sp,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPress: () {
                      playlistcontroller.clearSelections();
                      animationControllerX.reverseAnimation();
                    },
                  ),
                  Bubble(
                    title: "Delete",

                    iconColor: Colors.black,
                    bubbleColor: Theme.of(context).colorScheme.secondary,
                    icon: Icons.delete,
                    titleStyle: TextStyle(
                      fontSize: 8.sp,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPress: () {
                      playlistcontroller.deleteSelectedSongs();
                      animationControllerX.reverseAnimation();
                    },
                  ),
                  Bubble(
                    title: "Cancel",
                    iconColor: Colors.black,
                    bubbleColor: Theme.of(context).colorScheme.secondary,
                    icon: Icons.close,
                    titleStyle: TextStyle(
                      fontSize: 8.sp,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPress: () {
                      playlistcontroller.clearSelections();
                      animationControllerX.reverseAnimation();
                      playlistcontroller.toggleSelectionMode();
                    },
                  ),
                ],
                animatedIconData: AnimatedIcons.menu_arrow,
                animation: animationControllerX.animation,
                onPress: animationControllerX.toggleAnimation,
                backGroundColor: Theme.of(context).colorScheme.secondary,
                iconColor: Theme.of(context).colorScheme.inversePrimary,
              )
            : const SizedBox.shrink();
      }),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "A L L  M U S I C",
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Songlistwidget(),
    );
  }
}
