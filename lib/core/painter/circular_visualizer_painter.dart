import 'dart:math';

import 'package:flutter/material.dart';

class NeumorphicLiquidPainter extends CustomPainter {
  final List<double> fftData;
  final Color surfaceColor; // secondary
  final Color highlightColor; // onPrimary
  final Color shadowColor; // primary
  final double intensity;

  NeumorphicLiquidPainter({
    required this.fftData,
    required this.surfaceColor,
    required this.highlightColor,
    required this.shadowColor,
    this.intensity = 35.0,
  });

 @override
void paint(Canvas canvas, Size size) {
  if (fftData.isEmpty) return;

  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width / 2;

  // We draw the shadow/glow slightly larger when the music is louder
  // double avgAmplitude = fftData.reduce((a, b) => a + b) / fftData.length;
  // double dynamicIntensity = intensity + (avgAmplitude * 20);

  _drawContinuousWave(canvas, center, radius, isInward: true);
  _drawContinuousWave(canvas, center, radius,  isInward: false);
}

  void _drawContinuousWave(
    Canvas canvas,
    Offset center,
    double radius, {
    required bool isInward,
  }) {
    final path = Path();
    final int points = fftData.length;
    final double angleStep = (2 * pi) / points;

    List<Offset> offsets = [];

    // 1. Calculate points around the circle
    for (int i = 0; i < points; i++) {
      final double magnitude = isInward
          ? (fftData[i] * intensity * 0.5) * -1
          : (fftData[i] * intensity);

      final double angle = (i * angleStep) - pi / 2;
      final double x = center.dx + (radius + magnitude) * cos(angle);
      final double y = center.dy + (radius + magnitude) * sin(angle);
      offsets.add(Offset(x, y));
    }

    // 2. Create smooth Cubic Bezier path
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < points; i++) {
      final p0 = offsets[(i - 1 + points) % points];
      final p1 = offsets[i];
      final p2 = offsets[(i + 1) % points];
      final p3 = offsets[(i + 2) % points];

      // Smoothing factor (0.2 is sweet for liquid, higher = more "loopy")
      const double smoothing = 0.25;

      // Calculate control points for cubicTo
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * smoothing,
        p1.dy + (p2.dy - p0.dy) * smoothing,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * smoothing,
        p2.dy - (p3.dy - p1.dy) * smoothing,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    path.close();

    // 3. Render the neumorphic style
    _applyNeumorphicStroke(canvas, path, isInward);
  }

  // DEFINITION OF THE MISSING METHOD
  void _applyNeumorphicStroke(Canvas canvas, Path path, bool isInward) {
    // A. The Shadow Path (Bottom Right offset)
    final shadowPaint = Paint()
      ..color = shadowColor.withOpacity(isInward ? 0.2 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.save();
    canvas.translate(2, 2); // Offset for neumorphic depth
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // B. The Highlight Path (Top Left offset)
    final highlightPaint = Paint()
      ..color = highlightColor.withOpacity(isInward ? 0.3 : 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    canvas.save();
    canvas.translate(-1, -1); // Counter-offset for lighting
    canvas.drawPath(path, highlightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NeumorphicLiquidPainter oldDelegate) => true;
}
