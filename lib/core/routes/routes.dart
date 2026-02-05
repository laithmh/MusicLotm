import 'package:get/get.dart';
import 'package:musiclotm/core/const/routesname.dart';
import 'package:musiclotm/core/middeleware/middeleware.dart';
import 'package:musiclotm/view/allmusic.dart';
import 'package:musiclotm/view/favorite.dart';
import 'package:musiclotm/view/navigator.dart';
import 'package:musiclotm/view/playlistscreen.dart';
import 'package:musiclotm/view/playscreen.dart';
import 'package:musiclotm/view/search.dart';
import 'package:musiclotm/view/settings.dart';
import 'package:musiclotm/view/splash.dart';
import 'package:musiclotm/view/tag_editor.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(
    name: "/",
    page: () => const SplashScreen(),
    middlewares: [Mymiddlware()],
  ),
  GetPage(name: Approutes.navbar, page: () => const Navigator()),
  GetPage(name: Approutes.allmusic, page: () => const Allmusicscreen()),
  GetPage(name: Approutes.play, page: () => const Playscreen()),
  GetPage(name: Approutes.playlistscreen, page: () => const Playlistpage()),
  GetPage(name: Approutes.search, page: () => SearchScreen()),
  GetPage(name: Approutes.settings, page: () => const Settings()),
  GetPage(name: Approutes.favorite, page: () => const Favorite()),

  GetPage(
  name: Approutes.tagEditor,
  page: () => TagEditorScreen(
    songId: Get.parameters['songId'] ?? '',
  ),
  transition: Transition.rightToLeft,
),
  //  GetPage(
  //     name: Approutes.contact,
  //     page: () => const ContactUs(),
  //   ),

  // GetPage(name: navbar, page: ()=>const Navigationbarwidget(),),
  // GetPage(name: navbar, page: ()=>const Navigationbarwidget(),),
  // GetPage(name: navbar, page: ()=>const Navigationbarwidget(),),
];
