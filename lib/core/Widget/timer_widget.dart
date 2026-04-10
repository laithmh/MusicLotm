// Create a timer indicator widget for your app bar
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';
import 'package:musiclotm/core/Widget/timer_dialog.dart';

class SleepTimerAppBarIndicator extends StatelessWidget {
  const SleepTimerAppBarIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<Settingscontroller>();

    return Obx(() {
      if (!settings.timerSet.value) {
        return const SizedBox();
      }

      return GestureDetector(
        onTap: () {
          showDialog(context: context, builder: (context) => TimerDialog());
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Row(
            children: [
              SizedBox(width: 4.w),
              Text(
                settings.formattedRemainingTime,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
