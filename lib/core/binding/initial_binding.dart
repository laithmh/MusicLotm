import 'package:get/get.dart';
import 'package:musiclotm/controller/animationcontroller.dart';
import 'package:musiclotm/controller/navigatorcontroller.dart';
import 'package:musiclotm/controller/playlistcontroller.dart';
import 'package:musiclotm/controller/searchcontroller.dart';
import 'package:musiclotm/controller/songscontroller.dart';
import 'package:musiclotm/controller/tag_editor_controller.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/function/generaterandomnumber.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent controllers (needed throughout the app)
    Get.put(Songscontroller(), permanent: true);
    Get.put(Navigatorcontroller(), permanent: true);

    Get.put(AnimationControllerX(), permanent: true);

    // Lazy controllers (initialized only when called)
    Get.lazyPut(() => Playlistcontroller());
    Get.lazyPut(() => GenerateRandomNumbers());
    Get.lazyPut(() => Searchcontroller());
    Get.lazyPut(() => VisualizerController());
    Get.lazyPut(() => TagEditorController());
  }
}
