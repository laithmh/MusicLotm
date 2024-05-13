import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

import 'package:musiclotm/core/Widget/neubox.dart';



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
    return Column(
      children: [
        Neubox(
          borderRadius: BorderRadius.circular(500),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: artUri == null
                  ? Icon(
                      Icons.music_note,
                      size: 1000.w,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(500),
                      child: Image.file(
                        File.fromUri(artUri!),
                        height: 1000.w,
                        fit: BoxFit.cover,
                      ),
                    )),
        ),
        const SizedBox(
          height: 10,
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
