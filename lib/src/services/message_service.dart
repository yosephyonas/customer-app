import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../helper/custom_trace.dart';
import '../helper/helper.dart';
import '../models/message.dart';

Future<List<Message>> getMessages(String rideId,
    {DateTime? lastMessage}) async {
  Map<String, dynamic> _queryParams = {
    'last_message_datetime':
        lastMessage != null ? lastMessage.toString() : null,
    'ride_id': rideId,
  };
  var response = await http.get(
      Helper.getUri('messages', queryParam: _queryParams),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    var data = json.decode(response.body)['data'];
    List<Message> messages = [];
    data.forEach((element) {
      messages.add(Message.fromJSON(element));
    });
    return messages;
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Message> sendMessage(String rideId,
    {String? message, File? file}) async {
  Map<String, String> body = <String, String>{
    'ride_id': rideId,
  };
  if (message != null && message.isNotEmpty) {
    body['message'] = message;
  }

  var request = http.MultipartRequest('POST', Helper.getUri('messages'));
  request.headers.addAll(<String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  });
  request.fields.addAll(body);

  if (file != null) {
    request.files.add(
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: basename(file.path),
      ),
    );
  }
  var response = await request.send().timeout(const Duration(seconds: 15));
  var data = json.decode(await response.stream.bytesToString());
  print(data);
  if (response.statusCode == HttpStatus.ok) {
    return Message.fromJSON(data['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.reasonPhrase);
    throw Exception(response.statusCode);
  }
}
