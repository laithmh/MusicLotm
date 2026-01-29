import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/painter/circular_visualizer_painter.dart';

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

    return SizedBox(
      width: diskSize,
      height: diskSize,
      child: Obx(() {
        if (!controller.isInitialized.value || !controller.isCapturing.value) {
          return Center(key: const ValueKey('static'), child: imageChild);
        }

        final fftData = controller.fftData.toList();

       // Calculate Kick Intensity (first 10% of the bars)
        final data = controller.fftData;
        int kickEnd = (data.length * 0.1).toInt().clamp(1, data.length);
        double kickAvg = data.sublist(0, kickEnd).reduce((a, b) => a + b) / kickEnd;
        
        // Elastic scale: 1.0 to 1.18
        double bassScale = 1.0 + (kickAvg * 0.18).clamp(0.0, 0.2);

        return Stack(
          key: const ValueKey('active'),
          alignment: Alignment.center,
          children: [
            // 2. The Neumorphic Liquid Visualizer
            CustomPaint(
              size: Size(diskSize * 0.72, diskSize * 0.72),
              painter: NeumorphicLiquidPainter(
                fftData: fftData,
                surfaceColor: colorScheme.secondary,
                highlightColor: colorScheme.onPrimary,
                shadowColor: colorScheme.primary,
                intensity: 30 + (kickAvg * 20),
              ),
            ),

            // 3. Pulsing Neumorphic Album Art
            AnimatedScale(
              scale: bassScale,
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeInOutBack,
              child: Container(
                width: diskSize * 0.65,
                height: diskSize * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      offset: const Offset(8, 8),
                      blurRadius: 16,
                    ),
                    BoxShadow(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      offset: const Offset(-8, -8),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ClipOval(child: imageChild),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
