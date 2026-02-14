import 'dart:async';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingscontroller extends GetxController {
  late final Box _box;
  RxBool isDarkMode = false.obs;

  // Sleep Timer Variables
  RxBool timerSet = false.obs;
  RxBool timerEnds = false.obs;
  RxInt time = 0.obs; // Total minutes set

  // Timer functionality
  Timer? _sleepTimer;
  Rx<DateTime?> timerEndTime = Rx<DateTime?>(null);
  Rx<Duration> remainingTime = Duration.zero.obs;
  RxInt totalMinutesSet = 0.obs;

  // Contact Us
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Timer controllers
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();

  // App info
  final RxString appVersion = ''.obs;
  final RxString appBuildNumber = ''.obs;
  final RxString appName = ''.obs;
  final RxString packageName = ''.obs;

  // Contact info
  final String developerEmail = 'ponishermh97@gmail.com';
  final String appStoreUrl =
      'https://apps.apple.com/app/idYOUR_APP_ID'; // Replace with actual
  final String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.yourapp'; // Replace with actual
  final String privacyPolicyUrl =
      'https://yourapp.com/privacy'; // Replace with actual
  final String termsOfServiceUrl =
      'https://yourapp.com/terms'; // Replace with actual
  final String githubUrl =
      'https://github.com/yourusername/musiclotm'; // Replace with actual

  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> timerFormKey = GlobalKey<FormState>();

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  SongHandler get songHandler => Get.find<SongHandler>();
  AudioPlayer get audioPlayer => Get.find<AudioPlayer>();

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box("music");
    isDarkMode.value = _box.get("darkmode", defaultValue: false) ?? false;

    // Load saved timer state
    _loadTimerState();
    // Load app info
    _loadAppInfo();
  }

  void toggleTheme() {
    isDarkMode.toggle();
    _box.put("darkmode", isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
      appBuildNumber.value = packageInfo.buildNumber;
      appName.value = packageInfo.appName;
      packageName.value = packageInfo.packageName;
    } catch (e) {
      log('Error loading app info: $e');
      appVersion.value = '1.0.0';
      appBuildNumber.value = '1';
      appName.value = 'MusicLotM';
      packageName.value = 'com.musiclotm';
    }
  }

  void _loadTimerState() {
    try {
      // Load saved timer end time
      final savedEndTime = _box.get("timerEndTime");
      if (savedEndTime != null) {
        final endTime = DateTime.parse(savedEndTime);
        if (endTime.isAfter(DateTime.now())) {
          // Timer is still active
          timerEndTime.value = endTime;
          timerSet.value = true;
          _startTimerFromSaved(endTime);
        } else {
          // Timer has expired
          _box.delete("timerEndTime");
          timerSet.value = false;
        }
      }

      // Load timer duration
      time.value = _box.get("timerDuration", defaultValue: 0);
    } catch (e) {
      log('Error loading timer state: $e');
      timerSet.value = false;
    }
  }

  void _startTimerFromSaved(DateTime endTime) {
    final now = DateTime.now();
    final duration = endTime.difference(now);

    if (duration <= Duration.zero) {
      // Timer already expired
      timerSet.value = false;
      _box.delete("timerEndTime");
      time.value = 0;
      remainingTime.value = Duration.zero;
      return;
    }

    totalMinutesSet.value = duration.inMinutes;
    time.value = totalMinutesSet.value;
    remainingTime.value = duration;

    _startCountdownTimer(duration);
  }

  int setTimer() {
    final hourText = hourController.text.trim();
    final minuteText = minuteController.text.trim();

    // Handle empty strings properly
    int hours = 0;
    int minutes = 0;

    if (hourText.isNotEmpty) {
      hours = int.tryParse(hourText) ?? 0;
    }

    if (minuteText.isNotEmpty) {
      minutes = int.tryParse(minuteText) ?? 0;
    }

    // Validate input ranges
    hours = hours.clamp(0, 23);
    minutes = minutes.clamp(0, 59);

    int totalMinutes = (hours * 60) + minutes;

    return totalMinutes;
  }

  void startTimer(int minutes) {
    if (minutes <= 0) {
      Get.snackbar('Error', 'Please enter a valid time');
      return;
    }

    // Cancel existing timer
    cancelTimer();

    // Set timer
    totalMinutesSet.value = minutes;
    time.value = minutes;
    timerSet.value = true;
    timerEnds.value = false;

    // Calculate end time
    final endTime = DateTime.now().add(Duration(minutes: minutes));
    timerEndTime.value = endTime;

    // Set initial remaining time
    remainingTime.value = Duration(minutes: minutes);

    // Save to storage
    _box.put("timerEndTime", endTime.toIso8601String());
    _box.put("timerDuration", minutes);

    // Start the countdown
    _startCountdownTimer(Duration(minutes: minutes));

    Get.snackbar(
      'Timer Set',
      'Sleep timer set for $minutes minutes',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void _startCountdownTimer(Duration initialDuration) {
    // Cancel any existing timer
    _sleepTimer?.cancel();

    // Set initial remaining time
    remainingTime.value = initialDuration;

    // Start countdown
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value <= Duration.zero) {
        timer.cancel();
        _onTimerEnd();
        return;
      }

      // Update remaining time
      remainingTime.value = remainingTime.value - const Duration(seconds: 1);

      // Update time in minutes for display
      final minutesLeft = remainingTime.value.inMinutes;
      time.value = minutesLeft > 0 ? minutesLeft : 0;
    });
  }

  void cancelTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    timerSet.value = false;
    timerEnds.value = true;
    time.value = 0;
    totalMinutesSet.value = 0;
    timerEndTime.value = null;
    remainingTime.value = Duration.zero;

    // Clear storage
    _box.delete("timerEndTime");
    _box.delete("timerDuration");

    Get.snackbar(
      'Timer Cancelled',
      'Sleep timer has been cancelled',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void _onTimerEnd() async {
    _sleepTimer?.cancel();

    timerSet.value = false;
    timerEnds.value = false;
    time.value = 0;
    totalMinutesSet.value = 0;
    remainingTime.value = Duration.zero;
    timerEndTime.value = null;

    // Clear storage
    _box.delete("timerEndTime");
    _box.delete("timerDuration");

    // Exit app
    await exitAppWithDelay();
  }

  String get formattedRemainingTime {
    if (!timerSet.value || remainingTime.value <= Duration.zero) {
      return '';
    }

    final duration = remainingTime.value;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> exitAppWithDelay() async {
    try {
      // Fade out volume before stopping
      await _fadeOutVolume();

      await songHandler.stop();
      await Future.delayed(const Duration(milliseconds: 500));
      SystemNavigator.pop();
    } catch (e) {
      debugPrint('Error stopping audio service: $e');
      SystemNavigator.pop();
    }
  }

  Future<void> _fadeOutVolume() async {
    try {
      final currentVolume = audioPlayer.volume;
      const fadeDuration = Duration(seconds: 3);
      const steps = 30;
      Duration stepDuration = fadeDuration ~/ steps;

      for (int i = steps; i >= 0; i--) {
        final newVolume = currentVolume * (i / steps);
        await audioPlayer.setVolume(newVolume);
        await Future.delayed(stepDuration);
      }

      // Restore original volume
      await audioPlayer.setVolume(currentVolume);
    } catch (e) {
      log('Error fading out volume: $e');
    }
  }

  // Contact Us Functions - Updated for device_info_plus 12.3.0
  Future<void> sendContactEmail() async {
    if (!contactFormKey.currentState!.validate()) {
      return;
    }

    try {
      final String subject =
          '${appName.value} Feedback from ${nameController.text}';
      final String body =
          '''
Name: ${nameController.text}
Email: ${emailController.text}

Message:
${messageController.text}

--- Device Information ---
App: ${appName.value}
Version: ${appVersion.value} (${appBuildNumber.value})
Package: ${packageName.value}
Platform: ${GetPlatform.isAndroid ? 'Android' : 'iOS'}

${await _getDeviceInfoString()}
''';

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: developerEmail,
        queryParameters: {'subject': subject, 'body': body},
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        clearContactForm();
        Get.snackbar(
          'Success',
          'Email app opened successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not launch email app. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      Get.snackbar(
        'Error',
        'Failed to send email: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String> _getDeviceInfoString() async {
    try {
      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '''
Device Model: ${androidInfo.model}
Manufacturer: ${androidInfo.manufacturer}
Brand: ${androidInfo.brand}
Device: ${androidInfo.device}
Product: ${androidInfo.product}
Android Version: ${androidInfo.version.release}
SDK Version: ${androidInfo.version.sdkInt}
Board: ${androidInfo.board}
Hardware: ${androidInfo.hardware}
Is Physical Device: ${androidInfo.isPhysicalDevice}
''';
      } else {
        return 'Unknown platform';
      }
    } catch (e) {
      return 'Error getting device info: $e';
    }
  }

  Future<void> sendErrorReport(String errorDetails) async {
    try {
      final String subject = '${appName.value} Error Report';
      final String body =
          '''
Error Details:
$errorDetails

--- App Information ---
App: ${appName.value}
Version: ${appVersion.value} (${appBuildNumber.value})
Package: ${packageName.value}
Platform: ${GetPlatform.isAndroid ? 'Android' : 'iOS'}

--- Device Information ---
${await _getDeviceInfoString()}
''';

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: developerEmail,
        queryParameters: {'subject': subject, 'body': body},
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        Get.snackbar(
          'Success',
          'Error report sent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not launch email app. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error sending error report: $e');
      Get.snackbar(
        'Error',
        'Failed to send error report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareApp() async {
    try {
      final String text =
          'Check out ${appName.value} - an amazing music player app!';
      final String url = GetPlatform.isAndroid ? playStoreUrl : appStoreUrl;

      await Share.share('$text\n$url');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rateApp() async {
    try {
      final String url = GetPlatform.isAndroid ? playStoreUrl : appStoreUrl;
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open app store',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open app store',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open URL',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open URL',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      Get.snackbar(
        'Copied',
        'Text copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy to clipboard',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your message';
    }
    if (value.length < 10) {
      return 'Message must be at least 10 characters';
    }
    return null;
  }

  String? validateHour(String? value) {
    if (value == null || value.isEmpty) return 'Hour is required';

    final parsedValue = int.tryParse(value);
    if (parsedValue == null) return 'Enter a valid number';
    if (parsedValue < 0 || parsedValue > 23) return 'Hour must be between 0-23';

    return null;
  }

  String? validateMinute(String? value) {
    if (value == null || value.isEmpty) return 'Minute is required';

    final parsedValue = int.tryParse(value);
    if (parsedValue == null) return 'Enter a valid number';
    if (parsedValue < 0 || parsedValue > 59) {
      return 'Minute must be between 0-59';
    }

    return null;
  }

  // Clear form methods
  void clearContactForm() {
    nameController.clear();
    emailController.clear();
    messageController.clear();
  }

  void clearTimerForm() {
    hourController.clear();
    minuteController.clear();
  }

  // Method to reset timer settings
  void resetTimer() {
    cancelTimer();
    clearTimerForm();
  }

  // Method to save timer settings
  void saveTimerSettings() {
    final totalTime = setTimer();
    _box.put("timerDuration", totalTime);
    _box.put("timerEnabled", timerSet.value);
  }

  // Method to load timer settings
  void loadTimerSettings() {
    final savedTime = _box.get("timerDuration", defaultValue: 0);
    final timerEnabled = _box.get("timerEnabled", defaultValue: false);

    time.value = savedTime;
    timerSet.value = timerEnabled;
  }

  // Method to format time display
  String formatTimeDisplay() {
    final hours = time.value ~/ 60;
    final minutes = time.value % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Get device info for debugging
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'board': androidInfo.board,
          'hardware': androidInfo.hardware,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'appName': appName.value,
          'appVersion': appVersion.value,
          'appBuild': appBuildNumber.value,
        };
      }
      return {'platform': 'Unknown'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  void onClose() {
    _sleepTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.onClose();
  }
}
