import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:musiclotm/core/Widget/navigationbarwidget.dart';
import 'package:musiclotm/core/Widget/neubox.dart';


import 'package:on_audio_query/on_audio_query.dart';

class Playlistpage extends StatelessWidget {
  const Playlistpage({super.key});

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      bottomNavigationBar: const Navigationbarwidget(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(
              letterSpacing: 5, fontWeight: FontWeight.bold, fontSize: 75.sp),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
      ),
      body: 
          ListView.builder(
              itemCount: null,
              itemBuilder: (BuildContext context, int index) {
                
                return Padding(
                  padding: const EdgeInsets.all(7),
                  child: Neubox(
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: const Text(""),
                      subtitle: const Text(""),
                      leading: const QueryArtworkWidget(
                        id: 2,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Icon(Icons.music_note),
                      ),
                      onTap: () async {
                       
                      },
                    ),
                  ),
                );
              },
            )
         
    );
  }
}
