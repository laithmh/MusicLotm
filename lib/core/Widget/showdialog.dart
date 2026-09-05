import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/core/model/playlist_model.dart';

class CustomAlertDialog extends StatelessWidget {
  final void Function()? onPressed;
  const CustomAlertDialog({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Playlistcontroller playlistcontroller = Get.find();
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add to Playlist',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.inversePrimary,
        ),
      ),
      content: SizedBox(
        height: 400.h,
        width: 300.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select playlists to add songs:',
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 16.h),
            // Use GetBuilder instead of Obx for better control
            GetBuilder<Playlistcontroller>(
              builder: (controller) {
                if (controller.playlists.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_add,
                            size: 60.w,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No playlists yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create a playlist first',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.playlists.length,
                    itemBuilder: (BuildContext context, index) {
                      AppPlaylist playlist = controller.playlists[index];
                      final isSelected = controller.selectedPlaylistIds
                          .contains(playlist.id);

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : colorScheme.secondary.withValues(alpha: 0.5),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.inversePrimary
                                : colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            leading: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.secondary,
                              ),
                              child: Icon(
                                Icons.queue_music,
                                color: isSelected
                                    ? colorScheme.inversePrimary
                                    : colorScheme.primary,
                                size: 24.w,
                              ),
                            ),
                            title: Text(
                              playlist.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inversePrimary,
                              ),
                            ),
                            subtitle: playlist.description!.isNotEmpty
                                ? Text(
                                    playlist.description!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: colorScheme.primary,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : null,
                            trailing: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (selected) {
                                  // Update the selection
                                  controller.selectPlaylist(playlist.id);
                                },
                                activeColor: colorScheme.inversePrimary,
                                checkColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            onTap: () {
                              // Update the selection
                              controller.selectPlaylist(playlist.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            playlistcontroller.clearSelections();
          },
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.inversePrimary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            elevation: 2,
          ),
          child: const Text('Add'),
        ),
      ],
      actionsPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    );
  }
}
