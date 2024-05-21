import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/core/Widget/customaudioimage.dart';
import 'package:musiclotm/core/Widget/customplaybutton.dart';
import 'package:musiclotm/core/Widget/playscreen/addplaylistbutton.dart';
import 'package:musiclotm/core/Widget/waveformwidget.dart';
import 'package:musiclotm/main.dart';

class Playscreen extends StatelessWidget {
  const Playscreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
        stream: songHandler.mediaItem.stream,
        builder: (context, snapshot) {
          MediaItem? song = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == null) {
            return Text('Error: ${snapshot.error}');
          } else {
            findCurrentSongPlayingIndex(song!.id);
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  title: Text(
                    "P L A Y",
                    style:
                        TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                body: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, bottom: 25, top: 10),
                  child: Column(
                    children: [
                      Customaudioimage(
                        artist: song.artist!,
                        title: song.title,
                        artUri: song.artUri,
                        song: song,
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      const Addtoplaylistbutton(),
                      PolygonWaveformcustom(
                        maxDuration: song.duration!.inSeconds + 1,
                      ),
                      SizedBox(
                        height: 50.h,
                      ),
                      const Customplaybutton(),
                    ],
                  ),
                ));
          }
        });
  }
}
