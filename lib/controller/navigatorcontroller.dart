import 'package:get/get.dart';

class Navigatorcontroller extends GetxController {
  int currentindex = 0;

  changepage(int i) {
    currentindex = i;

    update();
  }
}
