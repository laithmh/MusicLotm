import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/Widget/playscreen/addplaylistbutton.dart';
import 'package:musiclotm/core/Widget/playscreen/customaudioimage.dart';
import 'package:musiclotm/core/Widget/playscreen/customplaybutton.dart';
import 'package:musiclotm/core/Widget/playscreen/titlefavo_widget.dart';
import 'package:musiclotm/core/Widget/playscreen/visualizer_widget.dart';
import 'package:musiclotm/core/Widget/playscreen/waveformwidget.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Playscreen extends StatefulWidget {
  const Playscreen({super.key});

  @override
  State<Playscreen> createState() => _PlayscreenState();
}

class _PlayscreenState extends State<Playscreen> {
  late Songscontroller songscontroller;
  late Playlistcontroller playlistcontroller;
  late VisualizerController visualizerController;
  late SongHandler songHandler;
  MediaItem? _currentSong;

  @override
  void initState() {
    super.initState();
    songscontroller = Get.find<Songscontroller>();
    playlistcontroller = Get.find<Playlistcontroller>();
    visualizerController = Get.find<VisualizerController>();
    songHandler = Get.find<SongHandler>();
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

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            title: Text(
              "NOW PLAYING",
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  Get.toNamed(
                    Approutes.tagEditor,
                    parameters: {'songId': _currentSong!.id},
                  );
                },
                icon: Icon(
                  Icons.edit_note_rounded,
                  size: 24.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Edit Tags',
              ),
            ],
          ),
          body: SafeArea(
            child: Obx(() {
              // Show loading state
              if (songscontroller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50.sp,
                        height: 50.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Loading Music...",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Please wait a moment",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show empty state
              if (songscontroller.songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off_rounded,
                        size: 80.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "No Music Found",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          "Add music to your device or check storage permissions",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          songscontroller.checkPermissionAndLoad();
                        },
                        icon: Icon(Icons.refresh, size: 18.sp),
                        label: Text(
                          'Refresh Library',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 14.h,
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // If still no current song, use first song
              _currentSong ??= songscontroller.songs.first;

              final currentSong = _currentSong!;
              final duration = currentSong.duration ?? const Duration();

              return Container(
                color: Theme.of(context).colorScheme.onPrimary,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 5.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Album Art with Visualizer
                            VisualizerImageWrapper(
                              diskSize: 300.w,
                              imageChild: Customaudioimage(
                                artUri: currentSong.artUri,
                                song: currentSong,
                              ),
                            ),

                            SizedBox(height: 0.h),

                            // Song Title and Artist
                            TitlefavoWidget(
                              song: currentSong,
                              artist: currentSong.artist ?? "Unknown Artist",
                              title: currentSong.title,
                            ),

                            SizedBox(height: 16.h),

                            // Time and Playlist Button
                            const Addtoplaylistbutton(),

                            SizedBox(height: 20.h),

                            // Waveform
                            if (duration.inSeconds > 0)
                              PolygonWaveformcustom(
                                maxDuration: duration.inSeconds > 0
                                    ? duration.inSeconds
                                    : 300,
                              ),

                            SizedBox(height: 20.h),

                            // Playback Controls
                            const Customplaybutton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
