import 'media.dart';
import 'create_ride_address.dart';

class User {
  late bool auth;
  bool isMercadoPagoConnected;
  String id;
  String name;
  String email;
  String phone;
  String token;
  String firebaseToken;
  String? password;
  Media? picture;
  List<CreateRideAddress> addresses;

  User({
    this.auth = false,
    this.isMercadoPagoConnected = false,
    this.id = "",
    this.name = "",
    this.email = "",
    this.token = "",
    this.firebaseToken = "",
    this.phone = "",
    this.addresses = const [],
  });

  User.fromJSON(Map<String, dynamic> jsonMap)
      : isMercadoPagoConnected = jsonMap['mp_connected'] ?? false,
        id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        email = jsonMap['email'] ?? '',
        phone = jsonMap['phone'] ?? '',
        token = jsonMap['api_token'] ?? '',
        firebaseToken = jsonMap['firebase_token'] ?? '',
        picture =
            jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
                ? Media.fromJSON(jsonMap['media'][0])
                : null,
        addresses = jsonMap['addresses'] != null
            ? jsonMap['addresses']
                    .map((address) => CreateRideAddress.fromJSON(address))
                    .toList()
                    .cast<CreateRideAddress>() ??
                []
            : [];

  Map<String, String> toJSON() {
    Map<String, String> json = {};
    json = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'api_token': token
    };
    if (password != null) {
      json.addAll({'password': password!});
    }
    return json;
  }

  Map toMapSocialRegister(String? photoUrl) {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    if (photoUrl != null) {
      map["photo_url"] = photoUrl;
    }
    return map;
  }
}
