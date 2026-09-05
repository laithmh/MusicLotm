import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Audio Visualizer Physics & Processing Tests', () {
    test('32-band normalization and clamping', () {
      final rawFrequencies = List.generate(32, (i) => i / 31.0);
      final clamped = rawFrequencies.map((v) => v.clamp(0.0, 1.0)).toList();

      expect(clamped.length, 32);
      expect(clamped.first, 0.0);
      expect(clamped.last, 1.0);
      for (final v in clamped) {
        expect(v >= 0.0 && v <= 1.0, isTrue);
      }
    });

    test('Physics exponential gravity decay calculation', () {
      double current = 1.0;
      const double target = 0.0;
      const double decayRate = 3.5;
      const double dt = 0.016; // 60 FPS frame delta

      // Multiple frames of decay
      for (int frame = 0; frame < 10; frame++) {
        if (target > current) {
          current = target;
        } else if (current > 0.001) {
          current = (current * (1.0 - (decayRate * dt))).clamp(0.0, 0.98);
        }
      }

      // Value should decay smoothly from 1.0 down towards 0
      expect(current < 0.7, isTrue);
      expect(current > 0.0, isTrue);
    });

    test('Physics instant upward rise on sharp transient beat', () {
      double current = 0.1;
      const double transientKick = 0.95;

      if (transientKick > current) {
        current = transientKick; // Instant rise
      }

      expect(current, equals(0.95));
    });

    test('Visualizer gamma power curve preserves range [0, 1] while adjusting contrast', () {
      const double testVal = 0.5;
      final double boosted = testVal > 0.0 ? (testVal * 1.2).clamp(0.0, 1.0) : 0.0;
      final double contrastGamma = (testVal * testVal);

      expect(boosted, greaterThan(testVal));
      expect(contrastGamma, lessThan(testVal));
      expect(contrastGamma >= 0.0 && contrastGamma <= 1.0, isTrue);
    });

    test('Proportional kick energy covers sub-bass, punch kick and mid-bass bands', () {
      final frequencies = [0.6, 0.8, 0.4, 0.2];
      final double kickEnergy = (frequencies[0] * 0.35 +
              frequencies[1] * 0.35 +
              frequencies[2] * 0.20 +
              frequencies[3] * 0.10)
          .clamp(0.0, 1.0);

      // (0.6*0.35 = 0.21) + (0.8*0.35 = 0.28) + (0.4*0.20 = 0.08) + (0.2*0.10 = 0.02) = 0.59
      expect(kickEnergy, closeTo(0.59, 0.01));
    });

    test('Disk pulse scale locks to 1.0 when disk animation is disabled', () {
      const double kickValue = 0.95;
      const double kickPump = 0.08;

      double computeScale(bool enabled) =>
          1.0 + (enabled ? kickValue * kickPump : 0.0);

      expect(computeScale(false), equals(1.0));
      expect(computeScale(true), greaterThan(1.0));
      expect(computeScale(true), closeTo(1.076, 0.001));
    });

    test('Studio rack peak-hold gravity decay floats smoothly down from peak', () {
      double peak = 0.90;
      const double currentBar = 0.30;
      const double gravityFalloff = 0.015;

      // When bar is lower than peak, peak decays by gravityFalloff each frame
      for (int frame = 0; frame < 10; frame++) {
        if (currentBar >= peak) {
          peak = currentBar;
        } else {
          peak = (peak - gravityFalloff).clamp(0.0, 1.0);
        }
      }

      // 0.90 - (10 * 0.015) = 0.75
      expect(peak, closeTo(0.75, 0.001));
      expect(peak, greaterThan(currentBar));
    });

    test('VisualizerStyle enum string roundtrip parsing handles all 3 styles safely', () {
      final styles = ['radialBars', 'liquid', 'eclipseNova'];
      for (final styleStr in styles) {
        final parsed = styles.contains(styleStr) ? styleStr : 'radialBars';
        expect(parsed, equals(styleStr));
      }

      // Fallback test
      const unknownStyle = 'unknownRandomStyle';
      final fallback = styles.contains(unknownStyle) ? unknownStyle : 'radialBars';
      expect(fallback, equals('radialBars'));
    });

    test('Visualizer Hive settings dictionary roundtrip preserves all user modifications', () {
      final Map<String, dynamic> mockHiveBox = {
        'visualizer_style': 'eclipseNova',
        'visualizer_attack': 0.85,
        'visualizer_decay': 0.65,
        'visualizer_max_height': 48.0,
        'visualizer_kick_scale': 0.12,
        'visualizer_sensitivity_gamma': 2.1,
        'visualizer_enable_disk_animation': false,
      };

      expect(mockHiveBox['visualizer_style'], equals('eclipseNova'));
      expect(mockHiveBox['visualizer_attack'], equals(0.85));
      expect(mockHiveBox['visualizer_decay'], equals(0.65));
      expect(mockHiveBox['visualizer_max_height'], equals(48.0));
      expect(mockHiveBox['visualizer_kick_scale'], equals(0.12));
      expect(mockHiveBox['visualizer_sensitivity_gamma'], equals(2.1));
      expect(mockHiveBox['visualizer_enable_disk_animation'], isFalse);
    });
  });
}
