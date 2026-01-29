import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';
import 'package:musiclotm/core/Widget/settingsdialog.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Srttings extends StatelessWidget {
  const Srttings({super.key});

  @override
  Widget build(BuildContext context) {
    Settingscontroller settingscontroller = Get.find();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            children: [
              Text(
                'S E T T I N G S',
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              Obx(
                () => settingscontroller.timerSet.isTrue
                    ? Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: TimerCountdown(
                                enableDescriptions: false,
                                format:
                                    CountDownTimerFormat.hoursMinutesSeconds,
                                endTime: DateTime.now().add(Duration(
                                  minutes: settingscontroller.time,
                                )),
                                onEnd: () {
                                  if (settingscontroller.timerEnds.isFalse) {
                                    log("Timer finished");
                                    settingscontroller.timerSet.value = false;

                                    settingscontroller.exitAppWithDelay();
                                  } else {
                                    log("timer cancel");
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            const Text("T O  S L E E P")
                          ],
                        ),
                      )
                    : const Text(""),
              ),
              SizedBox(
                height: 12.h,
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.only(left: 25.w, top: 25.h),
                child: ListTile(
                  title: const Text(
                    'D A R K M O D E',
                    style: TextStyle(),
                  ),
                  trailing: Obx(
                    () => Switch(
                      value: settingscontroller.isDarkMode.value,
                      onChanged: (value) {
                        settingscontroller.toggleTheme();
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 25.w, top: 25.h),
                  child: ListTile(
                    title: const Text(
                      'S L E E P  T I M E R',
                      style: TextStyle(),
                    ),
                    trailing: const Icon(Icons.timer_sharp),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => const Settingsdialog());
                    },
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.w, top: 25.h),
                  child: ListTile(
                    title: const Text(
                      'C O N T A C T  V I A  E M A I L',
                      style: TextStyle(),
                    ),
                    trailing: const Icon(Icons.email_outlined),
                    onTap: () {
                      Get.toNamed(
                        Approutes.contact,
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
