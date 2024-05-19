import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/main.dart';

class Settingscontroller extends GetxController {
  var box = Hive.box("music");
  RxBool isDarkMode = false.obs;
  RxBool timerset = false.obs;
  RxBool timerends = false.obs;
  late int time = settimer();
  TextEditingController hcontroller = TextEditingController();
  TextEditingController mcontroller = TextEditingController();

  void toggleTheme() {
    isDarkMode(!isDarkMode.value);
    box.put("darkmode", isDarkMode.value);
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
    songHandler.stop();
    SystemNavigator.pop();
  }

  @override
  void onInit() {
    
    super.onInit();
    isDarkMode.value = box.get("darkmode") ?? false;
  }
}
