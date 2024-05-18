import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Navigatorcontroller extends GetxController {
  int currentindex = 0;
  var box = Hive.box("music");
  changepage(int i) {
    currentindex = i;
    box.put("currenpagetindex", currentindex);
    update();
  }

  timer() {
    Timer(const Duration(seconds: 5), () {
      Get.offAllNamed(
        Approutes.navbar,
      );
    });
  }

  @override
  void onInit() async {
    super.onInit();
    timer();
    currentindex = await box.get("currenpagetindex") ?? 0;
  }
}
