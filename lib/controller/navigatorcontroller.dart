import 'dart:async';

import 'package:get/get.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Navigatorcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  int currentindex = 0;

  changepage(int i) {
    songscontroller.scroll();
    currentindex = i;

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
    currentindex = 2;
  }
}
