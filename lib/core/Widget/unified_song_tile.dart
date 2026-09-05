import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:on_audio_query/on_audio_query.dart';

class UnifiedSongTile extends StatelessWidget {
  final MediaItem song;
  final bool isPlaying;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback? onMoreOptions;

  const UnifiedSongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
    this.onSelectChanged,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final songHandler = Get.find<SongHandler>();

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: Neubox(
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                leading: _buildArtwork(context, colorScheme),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isPlaying
                        ? colorScheme.primary
                        : colorScheme.inversePrimary,
                  ),
                ),
                subtitle: Text(
                  song.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isPlaying
                        ? colorScheme.primary.withValues(alpha: 0.8)
                        : colorScheme.primary,
                  ),
                ),
                trailing: SizedBox(
                  width: onMoreOptions != null ? 70.w : 50.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isSelectionMode)
                        Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            checkColor: colorScheme.onPrimary,
                            activeColor: colorScheme.primary,
                            value: isSelected,
                            onChanged: onSelectChanged,
                          ),
                        )
                      else if (isPlaying)
                        StreamBuilder<PlaybackState>(
                          stream: songHandler.playbackState.stream,
                          builder: (context, snapshot) {
                            final isSongPlaying =
                                snapshot.data?.playing ?? false;
                            return SizedBox(
                              width: 26.w,
                              child: MiniMusicVisualizer(
                                color: colorScheme.primary,
                                width: 3,
                                height: 18,
                                radius: 1.5,
                                animate: isSongPlaying,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.secondary,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 16.sp,
                            color: colorScheme.primary,
                          ),
                        ),
                      if (onMoreOptions != null && !isSelectionMode) ...[
                        SizedBox(width: 4.w),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18.sp,
                            color: colorScheme.primary,
                          ),
                          onPressed: onMoreOptions,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.secondary,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: QueryArtworkWidget(
          id: int.tryParse(song.displayDescription ?? "0") ??
              int.tryParse(song.extras?['song_id']?.toString() ?? "0") ??
              0,
          keepOldArtwork: true,
          type: ArtworkType.AUDIO,
          artworkWidth: 100,
          artworkHeight: 100,
          artworkFit: BoxFit.cover,
          artworkQuality: FilterQuality.medium,
          nullArtworkWidget: Center(
            child: Icon(
              Icons.music_note,
              size: 24.sp,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
