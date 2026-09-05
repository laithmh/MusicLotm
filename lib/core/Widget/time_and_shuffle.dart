import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/song_handler.dart';

class TimeAndShuffleRow extends StatelessWidget {
  final String currentTime;
  final String duration;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onToggleLoop;
  final VoidCallback? onToggleShuffle;

  const TimeAndShuffleRow({
    super.key,
    required this.currentTime,
    required this.duration,
    required this.onAddToPlaylist,
    required this.onToggleLoop,
    required this.onToggleShuffle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final SongHandler songHandler = Get.find<SongHandler>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          currentTime,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.inversePrimary,
          ),
        ),
        IconButton(
          onPressed: onAddToPlaylist,
          icon: Icon(Icons.playlist_add, size: 24.sp, color: colorScheme.primary),
          tooltip: 'Add to playlist',
        ),
        Obx(() {
          final isLooping = songHandler.isLoop.value;
          return IconButton(
            onPressed: onToggleLoop,
            icon: Icon(
              isLooping ? Icons.repeat_one : Icons.repeat,
              size: 22.sp,
              color: isLooping
                  ? colorScheme.inversePrimary
                  : colorScheme.primary.withValues(alpha: 0.5),
            ),
            tooltip: isLooping ? 'Repeat one' : 'Repeat all',
          );
        }),
        Obx(() {
          final isShuffling = songHandler.isShuffle.value;
          return IconButton(
            onPressed: onToggleShuffle,
            icon: Icon(
              Icons.shuffle,
              size: 22.sp,
              color: isShuffling
                  ? colorScheme.inversePrimary
                  : colorScheme.primary.withValues(alpha: 0.5),
            ),
            tooltip: isShuffling ? 'Shuffle on' : 'Shuffle off',
          );
        }),
        Text(
          duration,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }
}
