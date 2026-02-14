import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:audify/audify.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/song_handler.dart';

class VisualizerController extends GetxController {
  // Get dependencies
  SongHandler get songHandler => Get.find<SongHandler>();
  // Visualizer properties
  late AudifyController audify;
  RxList<double> fftData = <double>[].obs;
  RxList<double> peakData = <double>[].obs;
  RxBool isInitialized = false.obs;
  RxBool isCapturing = false.obs;

  RxDouble bassValue = 0.0.obs; // Dedicated bass intensity for the UI

  // Adjusted Configuration for better "snap"
  final int barCount = 100;
  final double attackFactor = 1; // Faster rise for better reactivity
  final double decayFactor =
      0.8; // Slightly faster decay to prevent "mushiness"
  final double noiseFloor = 0.5; // Increased to filter low-level noise

  // Stream subscriptions
  StreamSubscription<List<double>>? _fftSubscription;
  StreamSubscription<int?>? _sessionSubscription;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (isInitialized.value) return;
      // Initialize with empty data
      fftData.value = List.filled(barCount, 0.0);
      peakData.value = List.filled(barCount, 0.0);

      audify = AudifyController();

      // Wait for audio session
      _sessionSubscription = songHandler.sessionIdStream.listen((sessionId) {
        if (sessionId != null && !isInitialized.value && !_isDisposed) {
          _initializeWithSession(sessionId);
        }
      });

      // Check if already has session
      if (songHandler.sessionId != null) {
        _initializeWithSession(songHandler.sessionId!);
      }
    } catch (e) {
      log('Error initializing visualizer: $e');
    }
  }

  Future<void> _initializeWithSession(int sessionId) async {
    if (isInitialized.value || _isDisposed) return;

    try {
      await audify.initialize(audioSessionId: sessionId);
      isInitialized.value = true;
      _startCapture();
      log('Visualizer initialized with session: $sessionId');
    } catch (e) {
      log('Failed to initialize visualizer with session $sessionId: $e');
      await Future.delayed(const Duration(seconds: 2));
      if (songHandler.sessionId != null && !_isDisposed) {
        _initializeWithSession(songHandler.sessionId!);
      }
    }
  }

  void updateSessionId(int newSessionId) {
    if (isInitialized.value) {
      _stopCapture();
      isInitialized.value = false;
      _initializeWithSession(newSessionId);
    }
  }

  void _startCapture() {
    if (isCapturing.value || !isInitialized.value || _isDisposed) return;

    try {
      audify.startCapture();
      isCapturing.value = true;

      _fftSubscription = audify.fftStream.listen(
        _processFFTData,
        onError: (error) {
          log('FFT stream error: $error');
          _stopCapture();
        },
      );
    } catch (e) {
      log('Error starting capture: $e');
      isCapturing.value = false;
    }
  }

  // Updated logic in visualizer_controller.dart
  void _processFFTData(List<double> frequencies) {
    if (frequencies.isEmpty || _isDisposed) return;

    List<double> processed = List.filled(barCount, 0.0);

    // 1. Physical Constants for a "Real" feel
    const double realAttack = 0.85; // Sharp, instant jump on kicks
    const double realDecay = 0.75; // Faster drop for high-energy feel

    for (int i = 0; i < barCount; i++) {
      // 2. Logarithmic bias: gives bass more "room"
      double percent = i / barCount;
      int logIndex = (pow(
        frequencies.length,
        pow(percent, 0.7),
      )).toInt().clamp(0, frequencies.length - 1);

      // 3. Spatial Smoothing with heavier center weight
      double rawValue = frequencies[logIndex];
      if (logIndex > 0 && logIndex < frequencies.length - 1) {
        rawValue =
            (frequencies[logIndex - 1] * 0.5) +
            frequencies[logIndex] +
            (frequencies[logIndex + 1] * 0.5);
        rawValue /= 2.0;
      }

      // 4. Frequency Sensitivity: Boost low-end kicks
      double boost = 1.0 + (percent * 3.5);
      if (i < barCount * 0.15) {
        boost *= 1.4; // Extra punch for the kick drum area
      }

      double target = (rawValue * boost).clamp(0.0, 1.2);
      if (target < noiseFloor) target = 0;

      // 5. Physics-based smoothing
      double previous = fftData[i];
      if (target > previous) {
        processed[i] = previous + (target - previous) * realAttack;
      } else {
        processed[i] = previous * realDecay;
      }
    }

    fftData.value = processed;
  }

  void _stopCapture() {
    isCapturing.value = false;
    _fftSubscription?.cancel();
    _fftSubscription = null;
    try {
      if (isInitialized.value) {
        audify.stopCapture();
      }
    } catch (e) {
      log('Error stopping capture: $e');
    }
  }

  void startVisualizer() {
    if (isInitialized.value && !isCapturing.value) {
      _startCapture();
    }
  }

  void stopVisualizer() {
    _stopCapture();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _stopCapture();
    _sessionSubscription?.cancel();
    audify.dispose();
    super.onClose();
  }
}
