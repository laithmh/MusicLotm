import 'package:get/get.dart';

import 'package:musiclotm/core/const/routesname.dart';
import 'package:musiclotm/view/allmusic.dart';
import 'package:musiclotm/view/favorite.dart';
import 'package:musiclotm/view/navigator.dart';
import 'package:musiclotm/view/playlistscreen.dart';
import 'package:musiclotm/view/playscreen.dart';
import 'package:musiclotm/view/search.dart';
import 'package:musiclotm/view/settings.dart';
import 'package:musiclotm/view/splash.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(
    name: "/",
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: Approutes.navbar,
    page: () => const Navigator(),
  ),
  GetPage(
    name: Approutes.allmusic,
    page: () => const Allmusicscreen(),
  ),
  GetPage(
    name: Approutes.play,
    page: () => const Playscreen(),
  ),
  GetPage(
    name: Approutes.playlistscreen,
    page: () => const Playlistpage(),
  ),
  GetPage(
    name: Approutes.search,
    page: () => const Search(),
  ),
  GetPage(
    name: Approutes.settings,
    page: () => const Srttings(),
  ),
  GetPage(
    name: Approutes.favorite,
    page: () => const Favorite(),
  ),

  // GetPage(name: navbar, page: ()=>const Navigationbarwidget(),),
  // GetPage(name: navbar, page: ()=>const Navigationbarwidget(),),
  // GetPage(name: navbar, page: ()=>const Navigationbarwidget(),),
];
