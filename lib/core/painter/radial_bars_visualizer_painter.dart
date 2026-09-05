import 'dart:math';
import 'package:flutter/material.dart';

class RadialBarsVisualizerPainter extends CustomPainter {
  final List<double> fftData;
  final Color primaryColor;
  final Color secondaryColor;
  final double baseRadius;
  final double maxBarHeight;
  final double barWidth;

  RadialBarsVisualizerPainter({
    required this.fftData,
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseRadius,
    this.maxBarHeight = 40.0,
    this.barWidth = 3.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fftData.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final int count = fftData.length;

    final Paint barPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;

    final int half = count ~/ 2;

    for (int i = 0; i < count; i++) {
      final double magnitude = fftData[i].clamp(0.0, 1.0);

      // Base bar height: 4px minimum so quiet bands are cleanly visible, scaling up with beat
      final double height = 4.0 + (magnitude * maxBarHeight);

      // Symmetrical angle: bass at bottom (pi/2), treble at top (-pi/2)
      final double angle = (i < half)
          ? (pi / 2) - (i * (pi / (half - 0.5)))
          : (-pi / 2) - ((i - half) * (pi / (half - 0.5)));

      final double cosA = cos(angle);
      final double sinA = sin(angle);

      final double startR = baseRadius;
      final double endR = baseRadius + height;

      final p1 = Offset(center.dx + startR * cosA, center.dy + startR * sinA);
      final p2 = Offset(center.dx + endR * cosA, center.dy + endR * sinA);

      // Gradient color interpolation based on magnitude
      final barColor = Color.lerp(secondaryColor, primaryColor, magnitude)!
          .withValues(alpha: (0.50 + magnitude * 0.50).clamp(0.0, 1.0));

      barPaint.color = barColor;
      canvas.drawLine(p1, p2, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadialBarsVisualizerPainter oldDelegate) => true;
}
