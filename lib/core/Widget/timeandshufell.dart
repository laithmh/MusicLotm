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
    SongHandler songHandler = Get.find<SongHandler>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          currenttime,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        IconButton(
          onPressed: addtoplaylist,
          icon: Icon(Icons.playlist_add, size: 22.w),
          tooltip: 'Add to playlist',
        ),
        Obx(() {
          return IconButton(
            onPressed: setloop,
            icon: songHandler.isloop.isFalse
                ? Icon(Icons.repeat, size: 22.w)
                : Icon(Icons.repeat_one, size: 22.w),
            tooltip: songHandler.isloop.isFalse ? 'Repeat all' : 'Repeat one',
          );
        }),
        Obx(() {
          return IconButton(
            onPressed: shuffle,
            icon: Icon(
              songHandler.isShuffel.value
                  ? Icons.arrow_right_alt
                  : Icons.shuffle,
              size: 22.w,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: songHandler.isShuffel.value ? 'Shuffle on' : 'Shuffle off',
          );
        }),
        Text(
          duraion,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
