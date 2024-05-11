import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

import 'package:musiclotm/core/routes/routes.dart';
import 'package:musiclotm/controller/song_handler.dart';


import 'package:get/get.dart';
import 'package:musiclotm/core/theme/themes.dart';

late SongHandler songHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  songHandler = await AudioService.init(
    builder: () => SongHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.laithmh.musiclotm.musiclotm',
      androidNotificationChannelName: 'MusicLotm Player',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Settingscontroller themeController = Get.put(Settingscontroller());
    return ScreenUtilInit(
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'music',
        theme: lightmode,
        darkTheme: darkmode,
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        getPages: routes,
      ),
      designSize: const Size(1344, 2992),
      minTextAdapt: true,
    );
  }
}
