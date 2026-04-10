import 'dart:async';

import 'package:get/get.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Navigatorcontroller extends GetxController {
  Songscontroller songscontroller = Get.find();
  RxInt currentindex = 0.obs;

  changepage(int i) {
    if (i == 0) {
      songscontroller.scrollToCurrentSong();
    }
    currentindex.value = i;

    
  }

  timer() {
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(
        Approutes.navbar,
      );
    });
  }

  @override
  void onInit() async {
    super.onInit();
    timer();
    currentindex.value = 2;
  }
}
