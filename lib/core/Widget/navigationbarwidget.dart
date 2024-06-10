import 'dart:math';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';

class Navigationbarwidget extends StatelessWidget {
  const Navigationbarwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Navigatorcontroller>(builder: (navigatorcontroller) {
      return CurvedNavigationBar(
        height: 200.h,
        animationCurve: Curves.easeOut,
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.background,
        animationDuration: const Duration(milliseconds: 400),
        index: navigatorcontroller.currentindex,
        iconPadding: 0,
        items: [
          CurvedNavigationBarItem(
            child: Neubox(
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.queue_music,
                size: 100.w,
              ),
            ),
          ),
          CurvedNavigationBarItem(
            child: Neubox(
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.library_music,
                size: 100.w,
              ),
            ),
          ),
          CurvedNavigationBarItem(
            child: Neubox(
              borderRadius: BorderRadius.circular(12),
              child: Icon(Icons.music_note, size: 100.w),
            ),
          ),
          CurvedNavigationBarItem(
            child: Neubox(
              borderRadius: BorderRadius.circular(12),
              child: Icon(Icons.search, size: 100.w),
            ),
          ),
          CurvedNavigationBarItem(
            child: Neubox(
              borderRadius: BorderRadius.circular(12),
              child: Icon(Icons.settings, size: 100.w),
            ),
          ),
        ],
        onTap: (index) {
          if (index == 0) {}
          navigatorcontroller.changepage(index);

          log(navigatorcontroller.currentindex);
          Get.back();
        },
      );
    });
  }
}
