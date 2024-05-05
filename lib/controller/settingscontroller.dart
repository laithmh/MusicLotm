import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Settingscontroller extends GetxController {
  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode(!isDarkMode.value);

    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void exitAppWithDelay(int minutes) {
    Timer(Duration(minutes: minutes), () {
      SystemNavigator.pop();
    });
  }
}
