import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:hive/hive.dart';
import 'package:musiclotm/core/const/routesname.dart';

class AppMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final box = Hive.box("music");
    final step = box.get("step")?.toString();

    if (step == "2") {
      return RouteSettings(name: Approutes.allmusic);
    }
    if (step == "1") {
      return RouteSettings(name: Approutes.play);
    }

    return null;
  }
}
