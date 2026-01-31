import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Customaudioimage extends StatelessWidget {
  final String artist;
  final String title;
  final Uri? artUri;
  final MediaItem song;

  const Customaudioimage({
    super.key,
    required this.artist,
    required this.title,
    required this.artUri,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    AnimationControllerX animationControllerX = Get.find();

    return Neubox(
      height: 220.h,
      width: 220.w,
      borderRadius: BorderRadius.circular(500.r),
      child: RotationTransition(
        turns: animationControllerX.animation,
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(1000),
          child: QueryArtworkWidget(
            key: ValueKey(song.id),
            keepOldArtwork: true,
            artworkBorder: BorderRadius.circular(1000),
            id: int.tryParse(song.displayDescription ?? "0") ?? 0,
            type: ArtworkType.AUDIO,
            artworkHeight: 540.h,
            artworkWidth: 540.h,
            artworkQuality: FilterQuality.high,
            artworkFit: BoxFit.cover,
            nullArtworkWidget: Container(
              width: double.infinity,
              height: double.infinity,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.music_note,
                size: 100.h,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
