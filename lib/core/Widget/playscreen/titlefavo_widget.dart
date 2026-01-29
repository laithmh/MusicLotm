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
    return Row(
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
                  fontWeight:
                      FontWeight.normal, // Changed: Normal weight for artist
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
    );
  }
}
