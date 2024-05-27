import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(Navigatorcontroller());

    return Scaffold(
      body: Center(
        child: Icon(
          Icons.music_note,
          size: 350.h,
        ),
      ),
    );
  }
}
