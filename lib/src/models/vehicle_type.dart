import 'media.dart';

class VehicleType {
  String id;
  String name;
  double basePrice;
  Media? picture;
  bool isDefault;

  VehicleType({
    this.id = "",
    this.name = "",
    this.basePrice = 0.00,
    this.isDefault = false,
  });

  VehicleType.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        basePrice = jsonMap['base_price'] != null
            ? double.parse(jsonMap['base_price'].toString())
            : 0.00,
        picture = (jsonMap['has_media'] ?? false)
            ? Media.fromJSON(jsonMap['media'][0])
            : null,
        isDefault = jsonMap['default'] ?? false;
}
