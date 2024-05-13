import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import 'package:get/get.dart';

import 'package:musiclotm/controller/settingscontroller.dart';
import 'package:musiclotm/core/Widget/settingsdialog.dart';


class Srttings extends StatelessWidget {
  const Srttings({super.key});

  @override
  Widget build(BuildContext context) {
    Settingscontroller settingscontroller = Get.put(Settingscontroller());
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Text(
              'S E T T I N G S',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(
              height: 15,
            ),
            Obx(
              () => settingscontroller.timerset.isTrue
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20),
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
                              onEnd: () {
                                log("Timer finished");
                                settingscontroller.timerset.value = false;

                                settingscontroller.exitAppWithDelay();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text("T O  S L E E P")
                        ],
                      ),
                    )
                  : const Text(""),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 25),
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
                padding: const EdgeInsets.only(left: 25, top: 25),
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
            
          ],
        ),
      ),
    );
  }
}
