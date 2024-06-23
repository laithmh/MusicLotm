import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/main.dart';

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
        Obx(() => songHandler.isloop.isFalse
            ? IconButton(onPressed: setloop, icon: const Icon(Icons.repeat))
            : IconButton(
                onPressed: setloop, icon: const Icon(Icons.repeat_one))),
        Obx(() => songHandler.isShuffel.value
            ? IconButton(
                onPressed: shuffle, icon: const Icon(Icons.arrow_forward))
            : IconButton(onPressed: shuffle, icon: const Icon(Icons.shuffle))),
        Text(duraion)
      ],
    );
  }
}
