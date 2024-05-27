import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/view/allmusic.dart';
import 'package:musiclotm/view/playlist.dart';
import 'package:musiclotm/view/playscreen.dart';
import 'package:musiclotm/view/search.dart';
import 'package:musiclotm/view/settings.dart';

class Navigator extends StatelessWidget {
  const Navigator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Navigatorcontroller>(
      builder: (controller) => PopScope(
        child: Scaffold(
          bottomNavigationBar: const Navigationbarwidget(),
          body: IndexedStack(
            index: controller.currentindex,
            children: const [
              Allmusicscreen(),
              Playlistscreen(),
              Playscreen(),
              Search(),
              Srttings(),
            ],
          ),
        ),
      ),
    );
  }
}
