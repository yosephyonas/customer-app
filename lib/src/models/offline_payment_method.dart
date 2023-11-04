import 'media.dart';

class OfflinePaymentMethod {
  String id;
  String name;
  Media? picture;

  OfflinePaymentMethod({
    this.id = "",
    this.name = "",
  });

  OfflinePaymentMethod.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        picture =
            jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
                ? Media.fromJSON(jsonMap['media'][0])
                : null;

  Map<String, String> toJSON() {
    return {
      'id': id,
      'name': name,
    };
  }
}
