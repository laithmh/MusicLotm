import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/main.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingscontroller extends GetxController {
  late final Box _box;
  RxBool isDarkMode = false.obs;
  RxBool timerSet = false.obs;
  RxBool timerEnds = false.obs;
  int time = 0;

  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box("music");
    isDarkMode.value = _box.get("darkmode", defaultValue: false) ?? false;
  }

  void toggleTheme() {
    isDarkMode.toggle();
    _box.put("darkmode", isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  int setTimer() {
    final hourText = hourController.text.trim();
    final minuteText = minuteController.text.trim();

    int hours = int.tryParse(hourText) ?? 0;
    int minutes = int.tryParse(minuteText) ?? 0;

    // Validate input ranges
    hours = hours.clamp(0, 23);
    minutes = minutes.clamp(0, 59);

    int totalMinutes = (hours * 60) + minutes;
    time = totalMinutes;

    return totalMinutes;
  }

  Future<void> exitAppWithDelay() async {
    try {
      await songHandler.stop();
      SystemNavigator.pop();
    } catch (e) {
      debugPrint('Error stopping audio service: $e');
      SystemNavigator.pop(); // Force close if audio service fails
    }
  }

  Future<void> sendEmail() async {
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      final String email = 'ponishermh97@gmail.com';
      final String subject = 'App Error Report';
      final String body =
          '''Model: ${androidInfo.model}
Device: ${androidInfo.device}
Brand: ${androidInfo.brand}
OS Version: ${androidInfo.version.release}
SDK: ${androidInfo.version.sdkInt}

${messageController.text}''';

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': subject, 'body': body},
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Get.snackbar(
          "Error",
          "Could not launch email app. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      Get.snackbar(
        "Error",
        "Failed to send email: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Validation methods for form inputs
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
    if (parsedValue < 0 || parsedValue > 59)
      return 'Minute must be between 0-59';

    return null;
  }

  // Method to clear all controllers
  void clearControllers() {
    hourController.clear();
    minuteController.clear();
    messageController.clear();
  }

  // Method to reset timer settings
  void resetTimer() {
    timerSet.value = false;
    timerEnds.value = false;
    time = 0;
    hourController.clear();
    minuteController.clear();
  }

  // Method to save timer settings
  void saveTimerSettings() {
    final totalTime = setTimer();
    _box.put("timer_minutes", totalTime);
    _box.put("timer_enabled", timerSet.value);
  }

  // Method to load timer settings
  void loadTimerSettings() {
    final savedTime = _box.get("timer_minutes", defaultValue: 0) as int?;
    final timerEnabled =
        _box.get("timer_enabled", defaultValue: false) as bool?;

    time = savedTime ?? 0;
    timerSet.value = timerEnabled ?? false;
  }

  // Method to format time display
  String formatTimeDisplay() {
    final hours = time ~/ 60;
    final minutes = time % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    hourController.dispose();
    minuteController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
