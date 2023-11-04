import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/setting.dart';

ValueNotifier<Setting> setting = ValueNotifier(Setting());

Future<Setting> initSettings() async {
  Setting _setting = Setting();
  _setting.theme =
      await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.light;

  setting.value = _setting;

  return setting.value;
}
