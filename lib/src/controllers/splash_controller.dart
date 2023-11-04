import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SplashController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = ValueNotifier({});
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  SplashController() {
    scaffoldKey = GlobalKey<ScaffoldState>();

    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0, "Firebase": 0};
  }
}
