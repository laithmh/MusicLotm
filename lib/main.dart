import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:musiclotm/controller/settingscontroller.dart';
import 'package:musiclotm/controller/song_handler.dart';
import 'package:musiclotm/core/binding/initial_binding.dart';
import 'package:musiclotm/core/function/permission.dart';
import 'package:musiclotm/core/routes/routes.dart';
import 'package:musiclotm/core/service/playlist_service.dart';
import 'package:musiclotm/core/theme/themes.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeServices();
    runApp(const MyApp());
  } catch (e) {
    log('Critical Initialization Error: $e');
    runApp(InitializationErrorApp(error: e.toString()));
  }
}

/// Handles all async initialization before the app starts
Future<void> _initializeServices() async {
  // 1. Storage & Database
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  await Hive.openBox("music");

  // 2. Media Store & Permissions
  MediaStore.ensureInitialized();
  MediaStore.appFolder = "MusicLotm";
  await requestInitialPermissions();

  // 3. Audio Service Setup
  final player = AudioPlayer(
    handleAudioSessionActivation: true,
    androidApplyAudioAttributes: true,
  );
  Get.put(player); // Register player in GetX for easy access

  final songHandler = await AudioService.init(
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
      androidNotificationClickStartsActivity: true,
    ),
  );
  Get.put(songHandler);

  // 4. Core Business Services
  await AppPlaylistService.init();

  // Initialize Settings immediately for Theme detection
  Get.put(Settingscontroller());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access settings for theme management
    final settings = Get.find<Settingscontroller>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MusicLotM',
        theme: lightmode,
        darkTheme: darkmode,
        themeMode: settings.isDarkMode.isTrue
            ? ThemeMode.dark
            : ThemeMode.light,

        // Routing & Dependencies
        initialBinding: InitialBinding(), // All other controllers load here
        getPages: routes,
        initialRoute: "/", // Middleware in routes.dart handles the logic

        navigatorObservers: [HeroController()],
        builder: (context, child) {
          return MediaQuery(
            // Fix text scaling across different devices
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}

/// Fallback UI in case of a crash during startup
class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Failed to Launch',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => io.exit(1),
                  child: const Text('Close Application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
