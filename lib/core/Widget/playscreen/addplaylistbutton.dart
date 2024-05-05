import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/core/Widget/timeandshufell.dart';
import 'package:musiclotm/main.dart';

class Addtoplaylistbutton extends StatelessWidget {
  const Addtoplaylistbutton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Timerow(
        addtoplaylist: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    content: SizedBox(
                      height: 400,
                      width: 400,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: null,
                              itemBuilder: (BuildContext context, index) {
                                final RxList<bool> checkedItems = List.generate(
                                        index + 1, (index) => false,
                                        growable: false)
                                    .obs;
                                return Obx(
                                  () => CheckboxListTile(
                                    title: const Text(""),
                                    checkColor: Colors.white,
                                    activeColor: Colors.blueGrey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    checkboxShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    value: checkedItems[index],
                                    onChanged: (value) {
                                      checkedItems[index] = value!;
                                      if (value = true) {}
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MaterialButton(
                                onPressed: () {},
                                child: const Text("save"),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text("cancel"),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ));
        },
        currenttime: songHandler.audioPlayer.position.toString(),
        duraion: songHandler.audioPlayer.duration.toString(),
        setloop: () {},
        shuffle: () {},
      ),
    );
  }
}
