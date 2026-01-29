import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/function/generaterandomnumber.dart';
import 'package:musiclotm/main.dart';

class Customplaybutton extends StatelessWidget {
  const Customplaybutton({super.key});

  @override
  Widget build(BuildContext context) {
    GenerateRandomNumbers generateRandomNumbers = Get.find();

    return StreamBuilder<PlaybackState>(
        stream: songHandler.playbackState.stream,
        builder: (context, snapshot) {
          bool playing = snapshot.data?.playing ?? false;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  onTap: () {
                    songHandler.handlePlayBackPrevious();
                    generateRandomNumbers.generateRandomNumbers(60);
                  },
                  child: Neubox(
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.skip_previous,
                      size: 50.sp,
                    ),
                  )),
              SizedBox(
                width: 25.w,
              ),
              GestureDetector(
                  onTap: () {
                    if (playing) {
                      songHandler.pause();
                    } else {
                      songHandler.play();
                    }
                  },
                  child: Neubox(
                    borderRadius: BorderRadius.circular(250),
                    child: playing
                        ? Icon(
                            Icons.pause_rounded,
                            size: 70.sp,
                          )
                        : Icon(
                            Icons.play_arrow_rounded,
                            size: 70.sp,
                          ),
                  )),
              SizedBox(
                width: 25.w,
              ),
              GestureDetector(
                  onTap: () {
                    generateRandomNumbers.generateRandomNumbers(60);

                    songHandler.handlePlayBackNext();
                  },
                  child: Neubox(
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(
                        Icons.skip_next,
                        size: 50.sp,
                      ))),
            ],
          );
        });
  }
}
