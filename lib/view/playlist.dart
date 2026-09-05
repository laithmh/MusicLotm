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
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "Playlists",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: const Playlistwidget(),
    );
  }
}
