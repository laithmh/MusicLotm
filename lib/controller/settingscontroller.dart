import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

class Settingscontroller extends GetxController {
  RxBool isDarkMode = false.obs;
  RxBool timerset = false.obs;
  late int time=settimer();
  TextEditingController hcontroller = TextEditingController();
  TextEditingController mcontroller = TextEditingController();

  void toggleTheme() {
    isDarkMode(!isDarkMode.value);

    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  int settimer() {
    int? m = int.tryParse(mcontroller.text) ?? 0;
    int? h = int.tryParse(hcontroller.text) ?? 0;
    int hour = h * 60;
    int time = hour + m;
    return time;
  }

  void exitAppWithDelay() {
    SystemNavigator.pop();
  }
}
