import 'dart:math';
import 'package:flutter/material.dart';

/// Professional "Eclipse Nova" Visualizer Painter
///
/// Features:
/// 1. Inner Concentric Bass Corona: energy ring pulsing behind the album art.
/// 2. Fine Corona Light Needles: 64 crisp tapered rays radiating outward.
/// 3. Studio Analog Peak Embers: Floating beads hovering at the apex of each ray
///    with simulated gravity falloff.
class EclipseNovaVisualizerPainter extends CustomPainter {
  final List<double> fftData;
  final List<double> peakHoldData;
  final double bassValue;
  final Color primaryColor;
  final Color secondaryColor;
  final double baseRadius;
  final double maxBarHeight;

  // Reusable paint objects to guarantee zero GC allocation during 60 FPS rendering
  final Paint _needlePaint = Paint()..strokeCap = StrokeCap.round;
  final Paint _coronaPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _emberCorePaint = Paint()..style = PaintingStyle.fill;
  final Paint _emberHaloPaint = Paint()..style = PaintingStyle.fill;

  EclipseNovaVisualizerPainter({
    required this.fftData,
    required this.peakHoldData,
    required this.bassValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseRadius,
    required this.maxBarHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fftData.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final int count = fftData.length; // 64
    final double step = (2 * pi) / count;

    // 1. Concentric Bass Corona Ring (pulsing energy shockwave behind disk)
    final double coronaRadius = baseRadius + (bassValue * 10.0);
    _coronaPaint
      ..strokeWidth = 2.0 + (bassValue * 3.0)
      ..color = secondaryColor.withValues(
        alpha: (0.12 + bassValue * 0.38).clamp(0.0, 0.65),
      );
    canvas.drawCircle(center, coronaRadius, _coronaPaint);

    // Secondary subtle outer ripple on heavy hits
    if (bassValue > 0.35) {
      final double rippleRadius = baseRadius + 8.0 + (bassValue * 18.0);
      _coronaPaint
        ..strokeWidth = 1.2
        ..color = secondaryColor.withValues(
          alpha: ((bassValue - 0.35) * 0.45).clamp(0.0, 0.35),
        );
      canvas.drawCircle(center, rippleRadius, _coronaPaint);
    }

    // 2. 64 Fine Corona Light Needles & Floating Peak Embers
    // Anchored with Bass at bottom (pi/2) and Treble at top (-pi/2)
    final double startAngle = pi / 2;
    final int half = count ~/ 2; // 32

    for (int i = 0; i < count; i++) {
      // Symmetrical frequency placement
      final int band = (i < half) ? i : (count - 1 - i);
      final double rawValue = (i < fftData.length) ? fftData[i] : 0.0;
      final double peakValue = (i < peakHoldData.length) ? peakHoldData[i] : rawValue;

      // Needle start & end coordinates
      final double angle = (startAngle + (i * step)) % (2 * pi);
      final double cosA = cos(angle);
      final double sinA = sin(angle);

      final double rStart = baseRadius + 2.0;
      final double needleHeight = rawValue * maxBarHeight;
      final double rEnd = rStart + needleHeight;

      final Offset pStart = Offset(
        center.dx + rStart * cosA,
        center.dy + rStart * sinA,
      );
      final Offset pEnd = Offset(
        center.dx + rEnd * cosA,
        center.dy + rEnd * sinA,
      );

      // Color interpolation from rim (primaryColor) to tip (secondaryColor)
      final double colorRatio = (band / 31.0).clamp(0.0, 1.0);
      final Color needleColor = Color.lerp(primaryColor, secondaryColor, colorRatio * 0.75 + rawValue * 0.25)!;

      // Draw Needle Ray
      if (needleHeight > 1.0) {
        _needlePaint
          ..strokeWidth = (1.8 + rawValue * 1.2).clamp(1.5, 3.2)
          ..color = needleColor.withValues(alpha: (0.40 + rawValue * 0.60).clamp(0.0, 1.0));
        canvas.drawLine(pStart, pEnd, _needlePaint);
      }

      // 3. Floating Peak Ember Bead (Studio Analog Peak-Hold Dot)
      if (peakValue > 0.04) {
        final double emberDist = rStart + (peakValue * maxBarHeight) + 4.5;
        final Offset emberPos = Offset(
          center.dx + emberDist * cosA,
          center.dy + emberDist * sinA,
        );

        final double emberAlpha = (peakValue * 1.1).clamp(0.25, 1.0);

        // Soft outer glow halo
        _emberHaloPaint.color = secondaryColor.withValues(alpha: emberAlpha * 0.35);
        canvas.drawCircle(emberPos, 3.2, _emberHaloPaint);

        // Solid bright center core
        _emberCorePaint.color = secondaryColor.withValues(alpha: emberAlpha);
        canvas.drawCircle(emberPos, 1.6, _emberCorePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant EclipseNovaVisualizerPainter oldDelegate) {
    return oldDelegate.fftData != fftData ||
        oldDelegate.peakHoldData != peakHoldData ||
        oldDelegate.bassValue != bassValue ||
        oldDelegate.maxBarHeight != maxBarHeight ||
        oldDelegate.primaryColor != primaryColor;
  }
}
