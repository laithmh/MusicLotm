import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/main.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingscontroller extends GetxController {
  var box = Hive.box("music");
  RxBool isDarkMode = false.obs;
  RxBool timerset = false.obs;
  RxBool timerends = false.obs;
  late int time = settimer();
  TextEditingController hcontroller = TextEditingController();
  TextEditingController mcontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final messageController = TextEditingController();
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

  Future<void> sendEmail() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ponishermh97@gmail.com',
      queryParameters: {
        'subject': 'App Error Report',
        'body':
            'model: ${androidInfo.model}\'device: ${androidInfo.device}\brand: ${androidInfo.brand}\n\n${messageController.text}'
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar("", "could not send please try again");
    }
  }

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = box.get("darkmode") ?? false;
  }
}
