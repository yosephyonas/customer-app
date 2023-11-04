import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../helper/helper.dart';
import '../models/user.dart';

Future<bool> updateFirebaseToken(User? user, String? firebaseToken) async {
  print('firebaseToken ${firebaseToken}');
  String jsonSend = jsonEncode(<String, String>{
    'firebase_token': firebaseToken ?? '',
  });
  var response = await http
      .post(Helper.getUri('notifications/update_token'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonSend)
      .timeout(const Duration(seconds: 15));
  print('response ${response.body}');
  if (response.statusCode == HttpStatus.ok) {
    return true;
  } else {
    return false;
  }
}
