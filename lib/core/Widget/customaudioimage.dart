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
          borderRadius: BorderRadius.circular(1000.r),
          child: RotationTransition(
            turns: animationControllerX.rotationcontroller,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(1000),
                  child: QueryArtworkWidget(
                    artworkBorder: BorderRadius.circular(1000),
                    id: int.parse(song.displayDescription!),
                    type: ArtworkType.AUDIO,
                    artworkHeight: 1080.h,
                    artworkWidth: 1080.h,
                    artworkQuality: FilterQuality.high,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: Icon(
                      Icons.music_note,
                      size: 1080.h,
                    ),
                  ),
                )),
          ),
        ),
        SizedBox(
          height: 40.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 700.w,
                  height: 100.h,
                  child: Text(
                    title,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  artist,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GetBuilder<Playlistcontroller>(
              builder: (controller) => IconButton(
                  onPressed: () {
                    controller.favoritetoggel(song);
                  },
                  icon: controller.isfavorite.containsKey(song.id)
                      ? controller.isfavorite[song.id]!
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            )
                      : const Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                        )),
            )
          ],
        ),
      ],
    );
  }
}
