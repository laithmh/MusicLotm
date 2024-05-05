import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/Widget/neubox.dart';

import 'package:musiclotm/core/function/generaterandomnumber.dart';

class Customplaybutton extends StatelessWidget {
  const Customplaybutton({super.key});

  @override
  Widget build(BuildContext context) {
    SongHandler songhandler = SongHandler();

    GenerateRandomNumbers generateRandomNumbers =
        Get.put(GenerateRandomNumbers());

    return StreamBuilder<PlaybackState>(
      stream: songhandler.playbackState.stream,
      builder: (context, snapshot) {
          bool playing = snapshot.data!.playing;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    songhandler.skipToNext();
                    generateRandomNumbers.generateRandomNumbers(60);
                  },
                  child: Neubox(
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(
                      Icons.skip_previous,
                    ),
                  )),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                  onTap: () {
                    if (playing) {
                songhandler.pause();
              } else {
                songhandler.play();
              }
                        
                  },
                  child:  Neubox(
                      borderRadius: BorderRadius.circular(50),
                      child:playing
                ? const Icon(Icons.pause_rounded, )
                : const Icon(Icons.play_arrow_rounded,),
                      ))),
            
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    generateRandomNumbers.generateRandomNumbers(60);
                  },
                  child: Neubox(
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(Icons.skip_next))),
            ),
          ],
        );
      }
    );
  }
}
