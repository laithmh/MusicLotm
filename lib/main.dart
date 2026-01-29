import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/controller/settingscontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/function/generaterandomnumber.dart';
import 'package:musiclotm/core/function/permission.dart';
import 'package:musiclotm/core/routes/routes.dart';
import 'package:musiclotm/core/theme/themes.dart';
import 'package:permission_handler/permission_handler.dart';

// Global instances
late AudioPlayer audioPlayer;
late Box box;
late SongHandler songHandler;

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    await Hive.initFlutter();
    box = await Hive.openBox("music");

    // Request permissions
    await requestInitialPermissions();

    // Create global audio player instance
    audioPlayer = AudioPlayer(
      handleAudioSessionActivation: true,
      androidApplyAudioAttributes: true,
    );

    // Initialize Audio Service
    songHandler = await AudioService.init(
      builder: () => SongHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.laithmh.musiclotm.channel',
        androidNotificationChannelName: 'MusicLotm Player',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'mipmap/ic_launcher',

        preloadArtwork: true,

        fastForwardInterval: Duration(seconds: 10),
        rewindInterval: Duration(seconds: 10),
      ),
    );
    // Initialize GetX controllers
    Get.put(AnimationControllerX());
    Get.put(Songscontroller());
    Get.put(Playlistcontroller());
    Get.put(Navigatorcontroller());
    Get.put(GenerateRandomNumbers());
    Get.put(Searchcontroller());
    Get.put(VisualizerController());
    Get.put(Settingscontroller());
    runApp(const MyApp());
  } catch (e) {
    log('Error during initialization: $e');
    // Show error dialog or fallback
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Error: $e'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => exit(1),
                  child: const Text('Exit App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MusicLotM',
          theme: lightmode,
          darkTheme: darkmode,
          themeMode: Get.find<Settingscontroller>().isDarkMode.isTrue
              ? ThemeMode.dark
              : ThemeMode.light,
          getPages: routes,
          initialRoute: '/splash',
          navigatorObservers: [HeroController()],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: const AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if permissions are granted
      final audioStatus = await Permission.audio.status;
      final storageStatus = await Permission.storage.status;

      if (!audioStatus.isGranted && !storageStatus.isGranted) {
        // Request permissions again if needed
        await [
          Permission.audio,
          Permission.storage,
          if (GetPlatform.isAndroid) Permission.notification,
        ].request();
      }

      // Initialize songs controller
      final songsController = Get.find<Songscontroller>();
      await songsController.loadSongs();
    } catch (e) {
      log('Error in app initialization: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is back in foreground
        break;
      case AppLifecycleState.inactive:
        // App is inactive (not in foreground but not terminated)
        break;
      case AppLifecycleState.paused:
        // App is in background
        break;
      case AppLifecycleState.detached:
        // App is terminated
        _cleanupResources();
        break;
      case AppLifecycleState.hidden:
        // App is hidden (rarely used)
        break;
    }
  }

  Future<void> _cleanupResources() async {
    try {
      // Stop audio service if running
      if (AudioService.running) {
        await AudioService.stop();
      }

      // Dispose audio player
      await audioPlayer.dispose();

      // Close Hive box
      if (box.isOpen) {
        await box.close();
      }
    } catch (e) {
      log('Error during cleanup: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This will be replaced by the initial route
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// Helper function to exit the app
void exit(int code) {
  // For mobile, we can't actually exit, so we show an error
  if (GetPlatform.isMobile) {
    Get.snackbar(
      'Cannot Exit',
      'Please use your device\'s back button or home button.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } else {
    // For desktop/web, we can exit
    // ignore: avoid_dynamic_calls
    (WidgetsBinding.instance as dynamic).exitApplication();
  }
}
