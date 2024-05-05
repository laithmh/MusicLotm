import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class Timerow extends StatelessWidget {
  final String currenttime;
  final String duraion;
  final void Function()? addtoplaylist;
  final void Function()? setloop;
  final void Function()? shuffle;
  const Timerow(
      {super.key,
      required this.currenttime,
      required this.duraion,
      required this.addtoplaylist,
      required this.setloop,
      required this.shuffle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(currenttime),
        IconButton(
            onPressed: addtoplaylist, icon: const Icon(Icons.playlist_add)),
        Obx(
          () => IconButton(onPressed: setloop, icon: const Icon(Icons.repeat)),
        ),
        Obx(() =>
            IconButton(onPressed: shuffle, icon: const Icon(Icons.shuffle))),
        Text(duraion)
      ],
    );
  }
}
