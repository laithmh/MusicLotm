import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/Widget/playscreen/addplaylistbutton.dart';
import 'package:musiclotm/core/Widget/playscreen/customaudioimage.dart';
import 'package:musiclotm/core/Widget/playscreen/customplaybutton.dart';
import 'package:musiclotm/core/Widget/playscreen/titlefavo_widget.dart';
import 'package:musiclotm/core/Widget/playscreen/visualizer_widget.dart';
import 'package:musiclotm/core/Widget/playscreen/waveformwidget.dart';
import 'package:musiclotm/core/Widget/timer_widget.dart';
import 'package:musiclotm/core/const/routesname.dart';
import 'package:musiclotm/main.dart';

class Playscreen extends StatefulWidget {
  const Playscreen({super.key});

  @override
  State<Playscreen> createState() => _PlayscreenState();
}

class _PlayscreenState extends State<Playscreen> {
  late Songscontroller songscontroller;
  late Playlistcontroller playlistcontroller;
  late VisualizerController visualizerController;
  MediaItem? _currentSong;

  @override
  void initState() {
    super.initState();
    songscontroller = Get.find<Songscontroller>();
    playlistcontroller = Get.find<Playlistcontroller>();
    visualizerController = Get.find<VisualizerController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start visualizer when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visualizerController.startVisualizer();
    });
  }

  @override
  void dispose() {
    visualizerController.stopVisualizer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: songHandler.mediaItem.stream,
      builder: (context, snapshot) {
        // Get current song
        if (snapshot.hasData && snapshot.data != null) {
          _currentSong = snapshot.data!;
        } else {
          _currentSong = songHandler.mediaItem.value;
        }

        // If still no current song, try to get from songs list
        if (_currentSong == null && songscontroller.songs.isNotEmpty) {
          _currentSong = songscontroller.songs.first;
        }

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
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).disabledColor,
                    ),
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
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Check your music library or permissions",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      songscontroller.loadSongs();
                    },
                    child: Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        // If still no current song, use first song
        _currentSong ??= songscontroller.songs.first;

        final currentSong = _currentSong!;
        final duration = currentSong.duration ?? const Duration();

        return Scaffold(
          appBar: AppBar(
            leading: SleepTimerAppBarIndicator(),
            actions: [
              IconButton(
                onPressed: () {
                  Get.toNamed(
                    Approutes.tagEditor,
                    parameters: {'songId': currentSong.id},
                  );
                },
                icon: Icon(Icons.edit),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            title: Text(
              "N O W  P L A Y I N G",
              style: TextStyle(
                fontSize: 18.sp,
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
                    VisualizerImageWrapper(
                      diskSize: 280.w,
                      imageChild: Customaudioimage(
                        artist: currentSong.artist ?? "Unknown Artist",
                        title: currentSong.title,
                        artUri: currentSong.artUri,
                        song: currentSong,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Song title and favorite
                    TitlefavoWidget(
                      song: currentSong,
                      artist: currentSong.artist ?? "Unknown Artist",
                      title: currentSong.title,
                    ),

                    SizedBox(height: 15.h),

                    // Add to playlist button and time
                    const Addtoplaylistbutton(),

                    SizedBox(height: 20.h),

                    // Waveform
                    PolygonWaveformcustom(
                      maxDuration: duration.inSeconds > 0
                          ? duration.inSeconds
                          : 300,
                    ),

                    SizedBox(height: 20.h),

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
