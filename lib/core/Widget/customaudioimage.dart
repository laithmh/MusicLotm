import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
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

    return Column(
      children: [
        
        Neubox(
          height: 250.h,
          width: 250.w,
          borderRadius: BorderRadius.circular(500.r),
          child: RotationTransition(
            turns: animationControllerX
                .animation, // Fixed: Use the correct animation property
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(1000),
                child: QueryArtworkWidget(
                  key: ValueKey(
                    song.id,
                  ), // Use a key so Flutter knows specifically which song this is
                  keepOldArtwork: true,
                  artworkBorder: BorderRadius.circular(1000),
                  id: int.tryParse(song.id) ?? 0,
                  type: ArtworkType.AUDIO,
                  artworkHeight: 540.h,
                  artworkWidth: 540.h,
                  artworkQuality: FilterQuality.high,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Icon(Icons.music_note, size: 100.h),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              // Added: Proper expansion for title area
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Added: Better alignment
                children: [
                  SizedBox(
                    width: 350.w,
                    height: 50.h,
                    child: Text(
                      title,
                      maxLines: 1, // Added: Explicit max lines
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // Removed const: Widget rebuilds may need different instances
                        fontSize: 20.sp, // Added: Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    artist,
                    maxLines: 1, // Added: Explicit max lines
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      // Removed const: Widget rebuilds may need different instances
                      fontSize: 15.sp, // Added: Responsive font size
                      fontWeight: FontWeight
                          .normal, // Changed: Normal weight for artist
                      color: Theme.of(context).textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8), // Added: Subtle color
                    ),
                  ),
                ],
              ),
            ),
            GetBuilder<Playlistcontroller>(
              builder: (controller) => IconButton(
                onPressed: () {
                  controller.toggleFavorite(song);
                },
                icon: Icon(
                  controller.isfavorite.containsKey(song.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.isfavorite.containsKey(song.id)
                      ? Colors.red
                      : Theme.of(
                          context,
                        ).iconTheme.color, // Added: Theme-aware color
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
