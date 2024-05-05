import 'package:flutter/material.dart';

import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/core/function/generaterandomnumber.dart';

class PolygonWaveformcustom extends StatelessWidget {
  final void Function(double)? onChanged;
  final Duration? maxDuration;
  final Duration? elapsedDuration;
  final double max;
  final double value;
  const PolygonWaveformcustom({
    super.key, this.onChanged, this.maxDuration, this.elapsedDuration, required this.max, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    GenerateRandomNumbers generateRandomNumbers =
        Get.put(GenerateRandomNumbers());
    

    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              RectangleWaveform(
                samples: generateRandomNumbers.samples,
                height: 150.h,
                width: MediaQuery.of(context).size.width - 100,
                maxDuration: maxDuration,
                elapsedDuration: elapsedDuration,
                inactiveColor: Theme.of(context).colorScheme.primary,
                activeColor: Theme.of(context).colorScheme.inversePrimary,
                showActiveWaveform: true,
                absolute: true,
                isRoundedRectangle: true,
                activeBorderColor: Theme.of(context).colorScheme.background,
                inactiveBorderColor: Theme.of(context).colorScheme.background,
              ),
              RectangleWaveform(
                samples: generateRandomNumbers.samples,
                height: 150.h,
                width: MediaQuery.of(context).size.width - 100,
                maxDuration: maxDuration,
                elapsedDuration: elapsedDuration,
                inactiveColor: Theme.of(context).colorScheme.background,
                activeColor: Theme.of(context).colorScheme.primary,
                showActiveWaveform: true,
                absolute: true,
                isRoundedRectangle: true,
                invert: true,
                activeBorderColor: Theme.of(context).colorScheme.background,
                inactiveBorderColor: Theme.of(context).colorScheme.background,
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
              max: max,
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.background,
              inactiveColor: Theme.of(context).colorScheme.background,
            ),
          ),
        ],
      ),
    );
  }
}
