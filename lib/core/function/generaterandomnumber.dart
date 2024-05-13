import 'dart:math';

import 'package:get/get.dart';

class GenerateRandomNumbers extends GetxController {
  late List<double> samples;

  generateRandomNumbers(int count) {
    final random = Random();
    List<double> randomNumbers = [];

    for (int i = 0; i < count; i++) {
      double randomNumber = random.nextDouble() * 150;
      randomNumbers.add(randomNumber);
    }

    samples = randomNumbers;
  }

  @override
  void onInit() {
    super.onInit();
    generateRandomNumbers(60);
  }
}
