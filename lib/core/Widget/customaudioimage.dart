import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';

import 'package:musiclotm/core/Widget/neubox.dart';

import 'package:transparent_image/transparent_image.dart';

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
    return Neubox(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: artUri == null
                  ? Icon(
                      Icons.music_note,
                      size: 1000.w,
                    )
                  : FadeInImage(
                      height: 1000.w,
                      width: 350,
                      filterQuality: FilterQuality.high,
                      image: FileImage(File.fromUri(artUri!)),
                      placeholder: MemoryImage(kTransparentImage),
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        ));
  }
}
