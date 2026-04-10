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

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add to Playlist',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).disabledColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No playlists yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create a playlist first',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).disabledColor,
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
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha:  0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          leading: Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha:  0.2)
                                  : Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.queue_music,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                              size: 24.w,
                            ),
                          ),
                          title: Text(
                            playlist.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          subtitle: playlist.description!.isNotEmpty
                              ? Text(
                                  playlist.description!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
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
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              checkColor: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
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
            foregroundColor: Colors.grey.shade600,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
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
