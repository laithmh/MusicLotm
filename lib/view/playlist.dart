import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:musiclotm/core/Widget/playlist/floatingbuttonwidget.dart';
import 'package:musiclotm/core/Widget/playlist/playlistwidget.dart';



class Playlistscreen extends StatelessWidget {
  const Playlistscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const Floatingbuttonwidget(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "P L A Y  L I S T",
          style: TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Playlistwidget(),
    );
  }
}
