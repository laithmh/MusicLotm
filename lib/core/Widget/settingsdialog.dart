import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

class Settingsdialog extends StatelessWidget {
  const Settingsdialog({super.key});

  @override
  Widget build(BuildContext context) {
    Settingscontroller settingscontroller = Get.put(Settingscontroller());

    return Obx(() => settingscontroller.timerset.isTrue
        ? Padding(
            padding: EdgeInsets.only(left: 80.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: TimerCountdown(
                    enableDescriptions: false,
                    format: CountDownTimerFormat.hoursMinutesSeconds,
                    endTime: DateTime.now().add(Duration(
                      minutes: settingscontroller.time,
                    )),
                  ),
                ),
                SizedBox(
                  width: 60.w,
                ),
                MaterialButton(
                  onPressed: () {
                    settingscontroller.timerset.value = false;
                    settingscontroller.timerends.value = true;
                    settingscontroller.time = 0;
                    Get.back();
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text("C A N C E L "),
                ),
              ],
            ),
          )
        : AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: SizedBox(
              height: 650.h,
              width: 400.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("S E T  T I M E R  T O  S L E E P"),
                  SizedBox(
                    height: 50.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        height: 200.h,
                        width: 200.w,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: settingscontroller.hcontroller,
                            decoration: const InputDecoration(hintText: "H"),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onTapOutside: (value) {
                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.immersiveSticky);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50.w,
                      ),
                      const Text(":"),
                      SizedBox(
                        width: 50.w,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        height: 200.h,
                        width: 200.w,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: settingscontroller.mcontroller,
                            decoration: const InputDecoration(hintText: "M"),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onTapOutside: (value) {
                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.immersiveSticky);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  Row(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          settingscontroller.timerset.value = false;
                          settingscontroller.timerends.value = true;
                          settingscontroller.time = 0;
                          Get.back();
                        },
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text("C A N C E L "),
                      ),
                      SizedBox(
                        width: 50.w,
                      ),
                      MaterialButton(
                        onPressed: () {
                          settingscontroller.time =
                              settingscontroller.settimer();
                          settingscontroller.timerset.value = true;
                          log("${settingscontroller.time}");
                          settingscontroller.mcontroller.clear();
                          settingscontroller.hcontroller.clear();
                          Get.back();
                        },
                        color: Theme.of(context).colorScheme.primary,
                        child: const Text(" S A V E "),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }
}
