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
        floatingActionButton: GetBuilder(
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
                        titleStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        onPress: () {
                          showDialog(
                              context: context,
                              builder: (context) => CustomAlertDialog(
                                    onPressed: () {
                                      playlistcontroller
                                          .addSongsToSelectedPlaylists();

                                      Get.back();
                                      animationControllerX.animationController
                                          .reverse();
                                      playlistcontroller.toggleSelection();
                                    },
                                  ));
                        },
                      ),
                      // Floating action menu item
                      Bubble(
                        title: "select all ",
                        iconColor: Colors.black,
                        bubbleColor: Theme.of(context).colorScheme.secondary,
                        icon: Icons.select_all,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        onPress: () {
                          controller.animationController.reverse();
                        },
                      ),
                      //Floating action menu item
                      Bubble(
                        title: "cancel",
                        iconColor: Colors.black,
                        bubbleColor: Theme.of(context).colorScheme.secondary,
                        icon: Icons.close,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        onPress: () {
                          playlistcontroller.listsongsid.clear();
                          controller.animationController.reverse();
                          playlistcontroller.toggleSelection();
                        },
                      ),
                    ],
                    animatedIconData: AnimatedIcons.menu_arrow,
                    animation: controller.animation,
                    onPress: controller.toggleAnimation,
                    backGroundColor: Theme.of(context).colorScheme.secondary,
                    iconColor: Theme.of(context).colorScheme.inversePrimary,
                  )
                : const SizedBox.shrink();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            "A L L  M U S I C",
            style: TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const SingleChildScrollView(child: Songlistwidget()));
  }
}
