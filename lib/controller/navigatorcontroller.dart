import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Navigatorcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  int currentindex = 0;
  var box = Hive.box("music");
  changepage(int i) {
    songscontroller.scroll();
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
