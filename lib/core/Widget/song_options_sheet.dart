import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/Widget/showdialog.dart';
import 'package:musiclotm/core/const/routesname.dart';

class SongOptionsSheet {
  static void show({
    required BuildContext context,
    required MediaItem song,
    VoidCallback? onDelete,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final playlistcontroller = Get.find<Playlistcontroller>();
    final songHandler = Get.find<SongHandler>();

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Song Title Preview
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  song.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Options List
                _buildOptionItem(
                  context,
                  icon: Icons.playlist_add,
                  title: 'Add to Playlist',
                  onTap: () {
                    Get.back();
                    showDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                        onPressed: () async {
                          await playlistcontroller
                              .addSongToSelectedPlaylists(song.id);
                          Get.back();
                        },
                      ),
                    );
                  },
                ),

                Obx(() {
                  final isFav = playlistcontroller.isSongFavorited(song.id);
                  return _buildOptionItem(
                    context,
                    icon: isFav ? Icons.favorite : Icons.favorite_border,
                    title: isFav ? 'Remove from Favorites' : 'Add to Favorites',
                    iconColor: isFav ? Colors.redAccent : colorScheme.primary,
                    onTap: () {
                      playlistcontroller.toggleFavorite(song);
                      Get.back();
                    },
                  );
                }),

                _buildOptionItem(
                  context,
                  icon: Icons.edit_note_rounded,
                  title: 'Edit Audio Tags',
                  onTap: () {
                    Get.back();
                    Get.toNamed(
                      Approutes.tagEditor,
                      parameters: {'songId': song.id},
                    );
                  },
                ),

                _buildOptionItem(
                  context,
                  icon: Icons.queue_music,
                  title: 'Play Next',
                  onTap: () {
                    Get.back();
                    songHandler.addQueueItem(song);
                    Get.snackbar(
                      'Queue',
                      'Added "${song.title}" to play next',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: colorScheme.onPrimary,
                      colorText: colorScheme.inversePrimary,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),

                if (onDelete != null)
                  _buildOptionItem(
                    context,
                    icon: Icons.delete_outline,
                    title: 'Delete from Device',
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Get.back();
                      onDelete();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Neubox(
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: iconColor ?? colorScheme.primary,
            size: 20.sp,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.inversePrimary,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
