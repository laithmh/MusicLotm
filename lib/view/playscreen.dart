import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/core/Widget/customplaybutton.dart';
import 'package:musiclotm/core/Widget/playscreen/addplaylistbutton.dart';
import 'package:musiclotm/core/Widget/playscreen/customaudioimage.dart';
import 'package:musiclotm/core/Widget/playscreen/titlefavo_widget.dart';
import 'package:musiclotm/core/Widget/playscreen/visualizer_widget.dart';
import 'package:musiclotm/core/Widget/playscreen/waveformwidget.dart';
import 'package:musiclotm/main.dart';

class Playscreen extends StatefulWidget {
  const Playscreen({super.key});

  @override
  State<Playscreen> createState() => _PlayscreenState();
}

class _PlayscreenState extends State<Playscreen> {
  late Songscontroller songscontroller;

  @override
  void initState() {
    super.initState();
    songscontroller = Get.find<Songscontroller>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: songHandler.mediaItem.stream,
      builder: (context, snapshot) {
        // Show loading state
        if (songscontroller.isLoading.value) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "LOADING MUSIC LIBRARY...",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Show empty state
        if (songscontroller.songs.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off_rounded,
                    size: 80.w,
                    color: Theme.of(context).disabledColor,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "No songs found",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Check your music library or permissions",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Get current song
        MediaItem currentSong;
        if (snapshot.hasData && snapshot.data != null) {
          currentSong = snapshot.data!;
        } else {
          currentSong = songscontroller.songs.firstWhere(
            (song) => song.id == songHandler.mediaItem.value?.id,
            orElse: () => songscontroller.songs.first,
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            title: Text(
              "P L A Y",
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Visualizer with album art
                    VisualizerImageWrapper(
                      diskSize: 280.w,
                      imageChild: Customaudioimage(
                        artist: currentSong.artist ?? "Unknown Artist",
                        title: currentSong.title,
                        artUri: currentSong.artUri,
                        song: currentSong,
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Song title and favorite
                    TitlefavoWidget(
                      song: currentSong,
                      artist: currentSong.artist ?? "Unknown Artist",
                      title: currentSong.title,
                    ),

                    SizedBox(height: 12.h),

                    // Add to playlist button
                    const Addtoplaylistbutton(),

                    SizedBox(height: 15.h),

                    // Waveform with fixed height
                    PolygonWaveformcustom(
                      maxDuration: (currentSong.duration?.inSeconds ?? 0) + 2,
                    ),

                    SizedBox(height: 15.h),

                    // Playback controls
                    const Customplaybutton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
