import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:musiclotm/core/Widget/neubox.dart';



import 'package:on_audio_query/on_audio_query.dart';

class Customaudioimage extends StatelessWidget {
  final int id;
  final String musicname;
  final String artestname;
  

  const Customaudioimage(
      {super.key,
      required this.id,
      required this.musicname,
      required this.artestname,
      });

  @override
  Widget build(BuildContext context) {
  

    return Neubox(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: QueryArtworkWidget(
                artworkBorder: BorderRadius.circular(10),
                artworkHeight: 950.w,
                artworkWidth: 350,
                id: id,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: Icon(
                  Icons.music_note,
                  size: 950.w,
                ),
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
                        musicname,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      artestname,
                    ),
                  ],
                ),
                 IconButton(
                          onPressed: () {
                           
                          },
                          icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  
                             )
                     
                
              ],
            ),
          ],
        ));
  }
}
