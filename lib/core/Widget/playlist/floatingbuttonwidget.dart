import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

class Floatingbuttonwidget extends StatelessWidget {
  const Floatingbuttonwidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      backgroundColor: colorScheme.inversePrimary,
      onPressed: () {
        showCreatePlaylistDialog(context);
      },
      child: Icon(Icons.add, color: colorScheme.onPrimary),
    );
  }

  void showCreatePlaylistDialog(BuildContext context) {
    final controller = Get.find<Playlistcontroller>();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create New Playlist',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.inversePrimary,
          ),
        ),
        content: SizedBox(
          height: 200.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.playlistNameController,
                style: TextStyle(color: colorScheme.inversePrimary),
                decoration: InputDecoration(
                  labelText: 'Playlist Name',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  hintText: 'Enter playlist name',
                  hintStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: colorScheme.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.inversePrimary),
                  ),
                  prefixIcon: Icon(Icons.queue_music, color: colorScheme.primary),
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
                style: TextStyle(color: colorScheme.inversePrimary),
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  hintText: 'Add a description',
                  hintStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: colorScheme.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.inversePrimary),
                  ),
                  prefixIcon: Icon(Icons.description, color: colorScheme.primary),
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
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
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
                }
              } catch (e) {
                log('Error creating playlist: $e');
                Get.snackbar('Error', 'Failed to create playlist');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.inversePrimary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
