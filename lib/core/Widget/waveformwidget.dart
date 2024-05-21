import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/core/function/generaterandomnumber.dart';
import 'package:musiclotm/main.dart';

class PolygonWaveformcustom extends StatelessWidget {
  final int? maxDuration;
  const PolygonWaveformcustom({
    super.key,
    this.maxDuration,
  });

  @override
  Widget build(BuildContext context) {
    GenerateRandomNumbers generateRandomNumbers = Get.find();

    return StreamBuilder<Duration>(
        stream: AudioService.position,
        builder: (context, snapshot) {
          Duration? position = snapshot.data;
          int second = position?.inSeconds ?? 0;

          box.put("position", second);

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  RectangleWaveform(
                    samples: generateRandomNumbers.samples,
                    height: 150.h,
                    width: MediaQuery.of(context).size.width - 100,
                    maxDuration: Duration(seconds: maxDuration ?? 0),
                    elapsedDuration: position ?? const Duration(seconds: 0),
                    inactiveColor: Theme.of(context).colorScheme.primary,
                    activeColor: Theme.of(context).colorScheme.inversePrimary,
                    showActiveWaveform: true,
                    absolute: true,
                    isRoundedRectangle: true,
                    activeBorderColor: Theme.of(context).colorScheme.background,
                    inactiveBorderColor:
                        Theme.of(context).colorScheme.background,
                  ),
                  RectangleWaveform(
                    samples: generateRandomNumbers.samples,
                    height: 150.h,
                    width: MediaQuery.of(context).size.width - 100,
                    maxDuration: Duration(seconds: maxDuration ?? 0),
                    elapsedDuration: position ?? const Duration(seconds: 0),
                    inactiveColor: Theme.of(context).colorScheme.background,
                    activeColor: Theme.of(context).colorScheme.primary,
                    showActiveWaveform: true,
                    absolute: true,
                    isRoundedRectangle: true,
                    invert: true,
                    activeBorderColor: Theme.of(context).colorScheme.background,
                    inactiveBorderColor:
                        Theme.of(context).colorScheme.background,
                    borderWidth: 0,
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderOverlayShape(overlayRadius: 0),
                    trackShape: const RoundedRectSliderTrackShape()),
                child: Slider(
                  min: const Duration(seconds: 0).inSeconds.toDouble(),
                  max: maxDuration!.toDouble(),
                  value: position?.inSeconds.toDouble() ?? 0,
                  onChanged: (position) {
                    songHandler.seek(position.seconds);
                  },
                  activeColor: Theme.of(context).colorScheme.background,
                  inactiveColor: Theme.of(context).colorScheme.background,
                ),
              ),
            ],
          );
        });
  }
}
