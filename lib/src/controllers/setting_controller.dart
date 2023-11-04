import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/custom_trace.dart';
import '../models/setting.dart';
import '../repositories/setting_repository.dart';
import '../services/setting_service.dart';

class SettingController extends ControllerMVC {
  SettingController({bool doInitSettings: false}) {
    if (doInitSettings) {
      initSettings();
    }
  }

  Future<void> doGetSettings() async {
    await getSettings().then((Setting _setting) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', json.encode(_setting.toJSON()));
      setting.value = _setting;
      AdaptiveTheme.of(state!.context).setTheme(
        light: ThemeData(
          primaryColor: _setting.mainColor ?? Colors.black,
          highlightColor: _setting.highlightColor ?? Colors.white,
          scaffoldBackgroundColor: _setting.backgroundColor ?? Colors.white,
          backgroundColor: _setting.backgroundColor ?? Colors.white,
          colorScheme: const ColorScheme.light().copyWith(
            secondary: _setting.secondaryColor ?? Colors.black87,
            secondaryContainer: _setting.secondaryColor ?? Colors.black,
            primary: _setting.mainColor ?? Colors.grey[850],
          ),
          hintColor: Color.fromRGBO(235, 235, 235, 1),
        ),
        dark: ThemeData(
          primaryColor: _setting.mainColorDark ?? Colors.white,
          highlightColor: _setting.highlightColorDark ?? Colors.black,
          scaffoldBackgroundColor:
              _setting.backgroundColorDark ?? Colors.grey[850],
          backgroundColor: _setting.backgroundColorDark ?? Colors.grey[850],
          colorScheme: const ColorScheme.dark().copyWith(
            secondary: _setting.secondaryColorDark ?? Colors.white70,
            secondaryContainer: _setting.secondaryColorDark ?? Colors.white,
            primary: _setting.mainColorDark ?? Colors.grey[850],
          ),
        ),
      );
    }).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao buscar configurações';
    });
  }
}
