import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:musiclotm/core/const/routesname.dart';


class Mymiddlware extends GetMiddleware {
  @override
  int? get priority => 1;
    var  box = Hive.box("music");
  
  @override
  RouteSettings? redirect(String? route) {
    if (box.get("step").toString() == "2") {
      return  RouteSettings(name:Approutes.allmusic);
    }
    if (box.get("step").toString() == "1") {
      return  RouteSettings(name: Approutes.play);
    }

    return null;
  }
}