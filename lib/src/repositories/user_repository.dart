import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

const String userTableName = "user";

ValueNotifier<User> currentUser = ValueNotifier(User());

class UserRepository {
  UserRepository();

  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage storage = const FlutterSecureStorage();

    if (prefs.getBool('first_run') ?? true) {
      prefs.setBool('first_run', false);
    }

    String userString = await storage.read(key: 'current_user') ?? '';

    if (userString.isNotEmpty && !currentUser.value.auth) {
      currentUser.value = User.fromJSON(json.decode(userString));
      currentUser.value.auth = true;
    } else {
      currentUser.value.auth = false;
    }
    return currentUser.value;
  }

  Future<void> setUser(User user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'current_user', value: jsonEncode(user.toJSON()));
    user.auth = true;
    currentUser.value = user;
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();

    if (await storage.containsKey(key: 'current_user')) {
      var userString = await storage.read(key: 'current_user');
      if (userString != null) {
        currentUser.value = User.fromJSON(json.decode(userString.toString()));
      }
    }

    await storage.delete(key: 'current_user');
    currentUser.value = User();
  }
}
