import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

class TitlefavoWidget extends StatelessWidget {
  final String artist;
  final String title;
  final MediaItem song;
  const TitlefavoWidget({
    super.key,
    required this.artist,
    required this.title,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    final playlistcontroller = Get.find<Playlistcontroller>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 350.w,
                height: 50.h,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final isFavorite = playlistcontroller.isSongFavorited(song.id);

          return IconButton(
            onPressed: () async {
              playlistcontroller.toggleFavorite(song);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Colors.red
                  : Theme.of(context).iconTheme.color,
              size: 24.w,
            ),
          );
        }),
      ],
    );
  }
}
