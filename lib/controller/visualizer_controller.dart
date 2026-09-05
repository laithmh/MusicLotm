import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:musiclotm/controller/song_handler.dart';

enum VisualizerStyle { radialBars, liquid, eclipseNova }

class VisualizerNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class VisualizerController extends GetxController {
  // Dependencies
  SongHandler get songHandler => Get.find<SongHandler>();

  // Hive persistence keys
  static const String hiveKeyStyle = 'visualizer_style';
  static const String hiveKeyAttack = 'visualizer_attack';
  static const String hiveKeyDecay = 'visualizer_decay';
  static const String hiveKeyMaxHeight = 'visualizer_max_height';
  static const String hiveKeyKickScale = 'visualizer_kick_scale';
  static const String hiveKeySensitivityGamma = 'visualizer_sensitivity_gamma';
  static const String hiveKeyEnableDiskAnimation = 'visualizer_enable_disk_animation';

  Box? get _box => Hive.isBoxOpen('music') ? Hive.box('music') : null;
  final List<Worker> _persistenceWorkers = [];

  /// High-performance notifier for 60 FPS CustomPaint canvas isolation
  final VisualizerNotifier visualizerNotifier = VisualizerNotifier();
  List<double> rawFftData = List.filled(64, 0.0);
  List<double> rawPeakHoldData = List.filled(64, 0.0);
  double rawBassValue = 0.0;

  // Observables for UI
  final RxList<double> fftData = <double>[].obs;
  final RxList<double> peakHoldData = <double>[].obs;
  final RxDouble bassValue = 0.0.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final Rx<VisualizerStyle> currentStyle = VisualizerStyle.radialBars.obs;
  final RxBool isStudioOpen = false.obs;

  void toggleStyle() {
    switch (currentStyle.value) {
      case VisualizerStyle.radialBars:
        currentStyle.value = VisualizerStyle.liquid;
        break;
      case VisualizerStyle.liquid:
        currentStyle.value = VisualizerStyle.eclipseNova;
        break;
      case VisualizerStyle.eclipseNova:
        currentStyle.value = VisualizerStyle.radialBars;
        break;
    }
  }

  void toggleStudio() {
    isStudioOpen.value = !isStudioOpen.value;
  }

  // 64-point perimeter wave (32 bands symmetrical)
  final int barCount = 64;
  final double noiseFloor = 0.02;

  // Spectral Flux Beat & Kick Onset Tracker
  double _energyAvg = 0.0;
  double _beatPulse = 0.0;

  // Professional audio ballistics: responsive transient attack & fluid decay
  final RxDouble attack = 0.55.obs;
  final RxDouble decay = 0.78.obs;
  final RxDouble maxHeight = 36.0.obs;
  final RxDouble kickScale = 0.08.obs;
  final RxDouble sensitivityGamma = 1.5.obs;
  final RxBool enableDiskAnimation = true.obs;

  void resetDefaults() {
    attack.value = 0.55;
    decay.value = 0.78;
    maxHeight.value = 36.0;
    kickScale.value = 0.08;
    sensitivityGamma.value = 1.5;
    enableDiskAnimation.value = true;
    currentStyle.value = VisualizerStyle.radialBars;
    _saveSettings();
  }

  void saveSettingsNow() {
    _saveSettings();
  }

  void _loadSettings() {
    try {
      final box = _box;
      if (box == null) return;

      final savedStyle = box.get(hiveKeyStyle);
      if (savedStyle != null) {
        if (savedStyle is String) {
          currentStyle.value = VisualizerStyle.values.firstWhere(
            (e) => e.name == savedStyle,
            orElse: () => VisualizerStyle.radialBars,
          );
        } else if (savedStyle is int && savedStyle >= 0 && savedStyle < VisualizerStyle.values.length) {
          currentStyle.value = VisualizerStyle.values[savedStyle];
        }
      }

      final savedAttack = box.get(hiveKeyAttack);
      if (savedAttack is num) {
        attack.value = savedAttack.toDouble();
      }

      final savedDecay = box.get(hiveKeyDecay);
      if (savedDecay is num) {
        decay.value = savedDecay.toDouble();
      }

      final savedMaxHeight = box.get(hiveKeyMaxHeight);
      if (savedMaxHeight is num) {
        maxHeight.value = savedMaxHeight.toDouble();
      }

      final savedKickScale = box.get(hiveKeyKickScale);
      if (savedKickScale is num) {
        kickScale.value = savedKickScale.toDouble();
      }

      final savedGamma = box.get(hiveKeySensitivityGamma);
      if (savedGamma is num) {
        sensitivityGamma.value = savedGamma.toDouble();
      }

      final savedDiskAnim = box.get(hiveKeyEnableDiskAnimation);
      if (savedDiskAnim is bool) {
        enableDiskAnimation.value = savedDiskAnim;
      }
    } catch (e) {
      log('Error loading visualizer settings from Hive: $e');
    }
  }

  void _saveSettings() {
    try {
      final box = _box;
      if (box == null) return;

      box.put(hiveKeyStyle, currentStyle.value.name);
      box.put(hiveKeyAttack, attack.value);
      box.put(hiveKeyDecay, decay.value);
      box.put(hiveKeyMaxHeight, maxHeight.value);
      box.put(hiveKeyKickScale, kickScale.value);
      box.put(hiveKeySensitivityGamma, sensitivityGamma.value);
      box.put(hiveKeyEnableDiskAnimation, enableDiskAnimation.value);
    } catch (e) {
      log('Error saving visualizer settings to Hive: $e');
    }
  }

  void _setupPersistenceListeners() {
    // Discrete immediate saves
    _persistenceWorkers.add(ever(currentStyle, (_) => _saveSettings()));
    _persistenceWorkers.add(ever(enableDiskAnimation, (_) => _saveSettings()));

    // Debounced slider saves to prevent disk I/O thrashing during drag gestures
    _persistenceWorkers.add(
      debounce(attack, (_) => _saveSettings(), time: const Duration(milliseconds: 300)),
    );
    _persistenceWorkers.add(
      debounce(decay, (_) => _saveSettings(), time: const Duration(milliseconds: 300)),
    );
    _persistenceWorkers.add(
      debounce(maxHeight, (_) => _saveSettings(), time: const Duration(milliseconds: 300)),
    );
    _persistenceWorkers.add(
      debounce(kickScale, (_) => _saveSettings(), time: const Duration(milliseconds: 300)),
    );
    _persistenceWorkers.add(
      debounce(sensitivityGamma, (_) => _saveSettings(), time: const Duration(milliseconds: 300)),
    );
  }

  // Stream subscriptions & state
  StreamSubscription<List<double>>? _visualizerSubscription;
  StreamSubscription<PlaybackState>? _playbackSubscription;
  Timer? _decayTimer;
  bool _isDisposed = false;
  bool _isPlaying = false;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _setupPersistenceListeners();
    _initialize();
  }

  void _initialize() {
    try {
      if (isInitialized.value) return;
      fftData.value = List.filled(barCount, 0.0);
      peakHoldData.value = List.filled(barCount, 0.0);
      isInitialized.value = true;
      _startCapture();
    } catch (e) {
      log('Error initializing visualizer controller: $e');
    }
  }

  void _startCapture() {
    if (isCapturing.value || _isDisposed) return;

    try {
      isCapturing.value = true;
      _visualizerSubscription?.cancel();
      _visualizerSubscription = songHandler.visualizerStream.listen(
        _processFFTData,
        onError: (error) {
          log('Visualizer stream error: $error');
        },
      );

      _playbackSubscription?.cancel();
      _playbackSubscription = songHandler.playbackState.listen((state) {
        _isPlaying = state.playing;
        if (!_isPlaying) {
          _startDecayTimer();
        } else {
          _decayTimer?.cancel();
        }
      });
    } catch (e) {
      log('Error starting visualizer stream capture: $e');
      isCapturing.value = false;
    }
  }

  void _startDecayTimer() {
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isDisposed || _isPlaying) {
        timer.cancel();
        return;
      }
      bool hasValue = false;
      for (int i = 0; i < barCount; i++) {
        final double current = rawFftData[i];
        if (current > 0.005) {
          rawFftData[i] = current * 0.80;
          hasValue = true;
        } else {
          rawFftData[i] = 0.0;
        }
      }
      rawBassValue = (rawBassValue * 0.80).clamp(0.0, 1.0);
      visualizerNotifier.notify();
      if (!hasValue) {
        timer.cancel();
      }
    });
  }

  void _processFFTData(List<double> frequencies) {
    if (frequencies.isEmpty || _isDisposed || !_isPlaying) return;

    final List<double> rawTarget = List.filled(barCount, 0.0);
    final int len = frequencies.length;
    final int half = barCount ~/ 2; // 32

    final double gammaExp = sensitivityGamma.value / 1.5;

    // 1. Direct symmetrical 1:1 mapping: each of the 32 bands maps to its own bar
    for (int i = 0; i < barCount; i++) {
      final int band = (i < half) ? i : (barCount - 1 - i);
      final int freqIdx = band.clamp(0, len - 1);
      double val = frequencies[freqIdx];
      if (val < noiseFloor) {
        val = 0.0;
      } else if (gammaExp != 1.0) {
        val = pow(val, gammaExp).toDouble();
      }
      rawTarget[i] = val.clamp(0.0, 1.0);
    }

    // 2. Spatial smoothing: applied only for liquid mode to keep radial bars crisp & discrete
    final bool isLiquid = currentStyle.value == VisualizerStyle.liquid;
    List<double> targetData = rawTarget;

    if (isLiquid) {
      final List<double> smoothed = List.filled(barCount, 0.0);
      for (int i = 0; i < barCount; i++) {
        final double pMinus2 = rawTarget[(i - 2 + barCount) % barCount];
        final double pMinus1 = rawTarget[(i - 1 + barCount) % barCount];
        final double p0 = rawTarget[i];
        final double pPlus1 = rawTarget[(i + 1) % barCount];
        final double pPlus2 = rawTarget[(i + 2) % barCount];

        smoothed[i] = (pMinus2 * 0.10) +
            (pMinus1 * 0.20) +
            (p0 * 0.40) +
            (pPlus1 * 0.20) +
            (pPlus2 * 0.10);
      }
      targetData = smoothed;
    }

    // 3. Fluid Ballistics (responsive attack + natural exponential recoil)
    final double curAttack = attack.value;
    final double curDecay = decay.value;
    for (int i = 0; i < barCount; i++) {
      final double target = targetData[i];
      final double previous = rawFftData[i];

      if (target > previous) {
        rawFftData[i] = previous + (target - previous) * curAttack;
      } else {
        rawFftData[i] = previous * curDecay;
      }
    }

    // Peak-hold tracker with studio rack gravity falloff
    for (int i = 0; i < barCount; i++) {
      if (rawFftData[i] >= rawPeakHoldData[i]) {
        rawPeakHoldData[i] = rawFftData[i];
      } else {
        rawPeakHoldData[i] = max(0.0, rawPeakHoldData[i] - 0.015);
      }
    }

    // 4. Spectral-Flux Beat & Kick Onset Detector (Sub-bass, punch kicks, 808s: bands 0-3)
    final double b0 = frequencies.isNotEmpty ? frequencies[0] : 0.0;
    final double b1 = frequencies.length > 1 ? frequencies[1] : b0;
    final double b2 = frequencies.length > 2 ? frequencies[2] : b1;
    final double b3 = frequencies.length > 3 ? frequencies[3] : b2;

    // Weighted kick energy: punch kick (b1, b2) + deep sub-bass (b0)
    final double kickEnergy = (b0 * 0.35 + b1 * 0.35 + b2 * 0.20 + b3 * 0.10).clamp(0.0, 1.0);

    // Track running average energy for dynamic thresholding
    _energyAvg = (_energyAvg * 0.85) + (kickEnergy * 0.15);
    final double energyDelta = kickEnergy - _energyAvg;

    // Dynamic proportional kick transient
    if (energyDelta > 0.04 && kickEnergy > 0.12) {
      final double hitStrength = (kickEnergy * 0.75 + energyDelta * 1.5).clamp(0.0, 1.0);
      _beatPulse = max(_beatPulse, hitStrength);
    } else {
      _beatPulse = _beatPulse * 0.70;
    }

    final double targetBass = max(_beatPulse, kickEnergy);
    if (targetBass > rawBassValue) {
      rawBassValue = rawBassValue + (targetBass - rawBassValue) * 0.80;
    } else {
      rawBassValue = (rawBassValue * 0.74).clamp(0.0, 1.0);
    }

    // Fast batch notification strictly for CustomPaint without widget tree rebuilds
    visualizerNotifier.notify();
  }

  void _stopCapture() {
    isCapturing.value = false;
    _visualizerSubscription?.cancel();
    _visualizerSubscription = null;
    _playbackSubscription?.cancel();
    _playbackSubscription = null;
    _decayTimer?.cancel();
  }

  void startVisualizer() {
    if (!isCapturing.value) {
      _startCapture();
    }
  }

  void stopVisualizer() {
    _stopCapture();
  }

  @override
  void onClose() {
    _isDisposed = true;
    for (final worker in _persistenceWorkers) {
      worker.dispose();
    }
    _persistenceWorkers.clear();
    _saveSettings();
    _stopCapture();
    visualizerNotifier.dispose();
    super.onClose();
  }
}
