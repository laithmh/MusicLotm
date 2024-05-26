import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimationControllerX extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController rotationcontroller;
  RxBool isAnimating = false.obs;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();
    rotationcontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    stop();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: animationController);
    animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  void start() {
    rotationcontroller.repeat();
    isAnimating.value = true;
  }

  void stop() {
    rotationcontroller.stop();
    isAnimating.value = false;
  }

  void reset() {
    rotationcontroller.reset();
  }

  void toggleAnimation() {
    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    rotationcontroller.dispose();
    super.onClose();
  }
}
