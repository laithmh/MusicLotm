import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Customaudioimage extends StatelessWidget {
 
  final Uri? artUri;
  final MediaItem song;

  const Customaudioimage({
    super.key,
    
    required this.artUri,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Neubox(
      height: 220.h,
      width: 220.w,
      borderRadius: BorderRadius.circular(500.r),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(1000),
        child: QueryArtworkWidget(
          keepOldArtwork: true,
          artworkBorder: BorderRadius.circular(1000),
          id: int.tryParse(song.displayDescription ?? "0") ?? 0,
          type: ArtworkType.AUDIO,
          artworkHeight: 540.h,
          artworkWidth: 540.h,
          artworkQuality: FilterQuality.medium,
          artworkFit: BoxFit.cover,
          nullArtworkWidget: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            child: Icon(
              Icons.music_note,
              size: 100.h,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
