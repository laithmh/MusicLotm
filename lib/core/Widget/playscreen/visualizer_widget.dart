import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/painter/circular_visualizer_painter.dart';
import 'package:musiclotm/core/painter/eclipse_nova_visualizer_painter.dart';
import 'package:musiclotm/core/painter/radial_bars_visualizer_painter.dart';

class VisualizerImageWrapper extends StatelessWidget {
  final Widget imageChild;
  final double diskSize;

  const VisualizerImageWrapper({
    super.key,
    required this.imageChild,
    this.diskSize = 250,
  });

  @override
  Widget build(BuildContext context) {
    final VisualizerController controller = Get.find<VisualizerController>();
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        controller.toggleStyle();
        final String styleName;
        switch (controller.currentStyle.value) {
          case VisualizerStyle.radialBars:
            styleName = 'Trap Nation Radial Bars';
            break;
          case VisualizerStyle.liquid:
            styleName = 'Neumorphic Liquid Wave';
            break;
          case VisualizerStyle.eclipseNova:
            styleName = 'Eclipse Nova Corona';
            break;
        }
        Get.snackbar(
          'Visualizer Style',
          'Switched to: $styleName',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
          backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
          colorText: colorScheme.onSurface,
          margin: const EdgeInsets.all(16),
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        controller.toggleStudio();
      },
      child: Obx(() {
        final style = controller.currentStyle.value;
        final isStudio = controller.isStudioOpen.value;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // In studio mode, scale disk gracefully so radial bars have abundant headroom
        final double currentDiskSize = isStudio ? diskSize * 0.76 : diskSize;

        // Album art diameter and bar starting radius
        final double artSize = currentDiskSize * 0.58;
        final double baseRadius = (artSize / 2) + 4.0;

        // Live configurable amplitude and kick pump
        final double maxH = controller.maxHeight.value;
        final bool isDiskAnimationOn = controller.enableDiskAnimation.value;
        final double kickPump = isDiskAnimationOn ? controller.kickScale.value : 0.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: currentDiskSize,
          height: currentDiskSize,
          child: RepaintBoundary(
            child: Stack(
              key: const ValueKey('active'),
              alignment: Alignment.center,
              children: [
                // 1. Equalizer Visualizer Layer (Hardware-accelerated, isolated canvas repaint)
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: controller.visualizerNotifier,
                    builder: (context, _) {
                      final fftData = controller.rawFftData;
                      final kick = controller.rawBassValue;

                      if (style == VisualizerStyle.radialBars) {
                        return CustomPaint(
                          size: Size(currentDiskSize, currentDiskSize),
                          painter: RadialBarsVisualizerPainter(
                            fftData: fftData,
                            primaryColor: colorScheme.primary,
                            secondaryColor: colorScheme.inversePrimary,
                            baseRadius: baseRadius,
                            maxBarHeight: maxH + (kick * (maxH * 0.65)),
                            barWidth: 3.5,
                          ),
                        );
                      } else if (style == VisualizerStyle.liquid) {
                        return CustomPaint(
                          size: Size(artSize * 1.05, artSize * 1.05),
                          painter: NeumorphicLiquidPainter(
                            fftData: fftData,
                            surfaceColor: colorScheme.inversePrimary,
                            highlightColor: colorScheme.inversePrimary,
                            shadowColor: colorScheme.surface,
                            intensity: (maxH * 0.35) + (kick * (maxH * 0.40)),
                          ),
                        );
                      } else {
                        return CustomPaint(
                          size: Size(currentDiskSize, currentDiskSize),
                          painter: EclipseNovaVisualizerPainter(
                            fftData: fftData,
                            peakHoldData: controller.rawPeakHoldData,
                            bassValue: kick,
                            primaryColor: colorScheme.primary,
                            secondaryColor: colorScheme.inversePrimary,
                            baseRadius: baseRadius,
                            maxBarHeight: maxH + (kick * (maxH * 0.55)),
                          ),
                        );
                      }
                    },
                  ),
                ),

                // 2. Pulsing Neumorphic Album Art (Image element cached, only Transform matrix updates)
                AnimatedBuilder(
                  animation: controller.visualizerNotifier,
                  child: Container(
                    width: artSize,
                    height: artSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.6 : 0.25),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: (isDarkMode ? Colors.grey.shade800 : Colors.white).withValues(alpha: 0.7),
                          offset: const Offset(-3, -3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ClipOval(child: imageChild),
                    ),
                  ),
                  builder: (context, cachedDiskChild) {
                    final kick = controller.rawBassValue;
                    final bassScale = isDiskAnimationOn
                        ? 1.0 + (kick * kickPump).clamp(0.0, 0.20)
                        : 1.0;
                    return Transform.scale(
                      scale: bassScale,
                      child: cachedDiskChild,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
