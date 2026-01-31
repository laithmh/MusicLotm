import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

class Floatingbuttonwidget extends StatelessWidget {
  const Floatingbuttonwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showCreatePlaylistDialog(context);
      },
      child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
    );
  }

  void showCreatePlaylistDialog(BuildContext context) {
    final controller = Get.find<Playlistcontroller>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create New Playlist',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: SizedBox(
          height: 200.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.playlistNameController,
                decoration: InputDecoration(
                  labelText: 'Playlist Name',
                  hintText: 'Enter playlist name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.queue_music),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller.playlistDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add a description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.playlistNameController.clear();
              controller.playlistDescriptionController.clear();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final playlistName = controller.playlistNameController.text
                  .trim();

              if (playlistName.isEmpty) {
                Get.snackbar('Error', 'Playlist name cannot be empty');
                return;
              }

              try {
                final playlist = await controller.createNewPlaylist(
                  name: playlistName,
                  description: controller.playlistDescriptionController.text
                      .trim(),
                );

                if (playlist != null) {
                  Get.back();
                  controller.playlistNameController.clear();
                  controller.playlistDescriptionController.clear();

                  // Optional: Navigate to the new playlist
                  // Get.to(() => Playlistpage(
                  //   playlistId: playlist.id,
                  //   playlistName: playlist.name,
                  // ));
                }
              } catch (e) {
                log('Error creating playlist: $e');
                Get.snackbar('Error', 'Failed to create playlist');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
