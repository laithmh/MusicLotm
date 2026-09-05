import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final songHandler = Get.find<SongHandler>();
    final navigator = Get.find<Navigatorcontroller>();
    final audioPlayer = Get.find<AudioPlayer>();
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<MediaItem?>(
      stream: songHandler.mediaItem.stream,
      builder: (context, snapshot) {
        final song = snapshot.data ?? songHandler.mediaItem.value;
        if (song == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          child: GestureDetector(
            onTap: () {
              navigator.changepage(2);
              if (Navigator.canPop(context)) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Neubox(
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        children: [
                          // 1. Artwork Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 44.w,
                              height: 44.w,
                              child: QueryArtworkWidget(
                                id: int.tryParse(song.displayDescription ?? "0") ?? 0,
                                type: ArtworkType.AUDIO,
                                artworkWidth: 100,
                                artworkHeight: 100,
                                artworkFit: BoxFit.cover,
                                keepOldArtwork: true,
                                nullArtworkWidget: Container(
                                  color: colorScheme.secondary,
                                  child: Icon(
                                    Icons.music_note,
                                    size: 22.sp,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // 2. Song Title & Artist
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.inversePrimary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  song.artist ?? 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. Playback Controls
                          StreamBuilder<PlaybackState>(
                            stream: songHandler.playbackState.stream,
                            builder: (context, playSnapshot) {
                              final isPlaying =
                                  playSnapshot.data?.playing ?? false;

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Play / Pause button
                                  GestureDetector(
                                    onTap: () {
                                      if (isPlaying) {
                                        songHandler.pause();
                                      } else {
                                        songHandler.play();
                                      }
                                    },
                                    child: Neubox(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Padding(
                                        padding: EdgeInsets.all(6.w),
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 20.sp,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),

                                  // Skip Next button
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      songHandler.handlePlayBackNext();
                                    },
                                    icon: Icon(
                                      Icons.skip_next_rounded,
                                      size: 26.sp,
                                      color: colorScheme.inversePrimary,
                                    ),
                                    tooltip: 'Next',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 4. Subtle Mini Progress Bar
                    StreamBuilder<Duration>(
                      stream: AudioService.position,
                      builder: (context, posSnapshot) {
                        final pos = posSnapshot.data?.inMilliseconds ?? 0;
                        final duration =
                            audioPlayer.duration?.inMilliseconds ??
                            song.duration?.inMilliseconds ??
                            0;

                        final double progress = duration > 0
                            ? (pos / duration).clamp(0.0, 1.0)
                            : 0.0;

                        return LinearProgressIndicator(
                          value: progress,
                          minHeight: 2.h,
                          backgroundColor:
                              colorScheme.primary.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
