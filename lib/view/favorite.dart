import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';

import 'package:on_audio_query/on_audio_query.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const Navigationbarwidget(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "F A V O R I T E",
          style: TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: null,
        itemBuilder: (BuildContext context, int index) {
          return Neubox(
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              title: const Text(
                "",
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
              subtitle: const Text(""),
              leading: const QueryArtworkWidget(
                id: 1,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: Icon(Icons.music_note),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
