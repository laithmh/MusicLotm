import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

class Settingsdialog extends StatelessWidget {
  const Settingsdialog({super.key});

  @override
  Widget build(BuildContext context) {
    Settingscontroller settingscontroller = Get.put(Settingscontroller());

    return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: SizedBox(
          height: 650.h,
          width: 400.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("S E T  T I M E R  T O  S L E E P"),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).colorScheme.inversePrimary)),
                    height: 50,
                    width: 50,
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
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(":"),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).colorScheme.inversePrimary)),
                    height: 50,
                    width: 50,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  MaterialButton(
                    onPressed: () {
                      Get.back();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text("C A N C E L "),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                    onPressed: () {
                      settingscontroller.time = settingscontroller.settimer();
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
        ));
  }
}