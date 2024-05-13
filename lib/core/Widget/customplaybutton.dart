import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:musiclotm/core/Widget/neubox.dart';

import 'package:musiclotm/core/function/generaterandomnumber.dart';
import 'package:musiclotm/main.dart';

class Customplaybutton extends StatelessWidget {
  const Customplaybutton({super.key});

  @override
  Widget build(BuildContext context) {
    GenerateRandomNumbers generateRandomNumbers =
        Get.put(GenerateRandomNumbers());

    return StreamBuilder<PlaybackState>(
        stream: songHandler.playbackState.stream,
        builder: (context, snapshot) {
          bool playing = snapshot.data!.playing;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                    onTap: () {
                      songHandler.handlePlayBackPrevious();
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
                          songHandler.pause();
                        } else {
                          songHandler.play();
                        }
                      },
                      child: Neubox(
                        borderRadius: BorderRadius.circular(50),
                        child: playing
                            ? const Icon(
                                Icons.pause_rounded,
                              )
                            : const Icon(
                                Icons.play_arrow_rounded,
                              ),
                      ))),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: GestureDetector(
                    onTap: () {
                      generateRandomNumbers.generateRandomNumbers(60);

                      songHandler.handlePlayBackNext();
                    },
                    child: Neubox(
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(Icons.skip_next))),
              ),
            ],
          );
        });
  }
}
