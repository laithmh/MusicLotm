import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';



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
                        builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            content: SizedBox(
                              height: 600.h,
                              width: 400.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                      "S E T  T I M E R  T O  S L E E P"),
                                  const SizedBox(
                                    height: 10,
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
                                        height: 50,
                                        width: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            decoration:
                                                const InputDecoration(hintText: "H"),
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            onTapOutside: (value) {
                                              SystemChrome
                                                  .setEnabledSystemUIMode(
                                                      SystemUiMode
                                                          .immersiveSticky);
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
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary)),
                                        height: 50,
                                        width: 50,
                                        child:  Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            decoration:
                                                const InputDecoration(hintText: "M"),
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            onTapOutside: (value) {
                                              SystemChrome
                                                  .setEnabledSystemUIMode(
                                                      SystemUiMode
                                                          .immersiveSticky);
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
                                        onPressed: () {},
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: const Text("C A N C E L "),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      MaterialButton(
                                        onPressed: () {},
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: const Text(" S A V E "),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )));
                  },
                ))
          ],
        ),
      ),
    );
  }
}
