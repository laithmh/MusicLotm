import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/song_handler.dart';

class Timerow extends StatelessWidget {
  final String currenttime;
  final String duraion;
  final void Function()? addtoplaylist;
  final void Function()? setloop;
  final void Function()? shuffle;
  const Timerow({
    super.key,
    required this.currenttime,
    required this.duraion,
    required this.addtoplaylist,
    required this.setloop,
    required this.shuffle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final SongHandler songHandler = Get.find<SongHandler>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          currenttime,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.inversePrimary,
          ),
        ),
        IconButton(
          onPressed: addtoplaylist,
          icon: Icon(Icons.playlist_add, size: 24.sp, color: colorScheme.primary),
          tooltip: 'Add to playlist',
        ),
        Obx(() {
          final isLooping = songHandler.isloop.value;
          return IconButton(
            onPressed: setloop,
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
          final isShuffle = songHandler.isShuffel.value;
          return IconButton(
            onPressed: shuffle,
            icon: Icon(
              Icons.shuffle,
              size: 22.sp,
              color: isShuffle
                  ? colorScheme.inversePrimary
                  : colorScheme.primary.withValues(alpha: 0.5),
            ),
            tooltip: isShuffle ? 'Shuffle on' : 'Shuffle off',
          );
        }),
        Text(
          duraion,
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
