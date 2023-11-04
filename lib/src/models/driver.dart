import 'package:driver_customer_app/src/models/vehicle_type.dart';

import 'user.dart';

class Driver {
  bool active;
  String id;
  String link;
  User? user;
  double? basePrice;
  double? baseDistance;
  double? additionalDistancePricing;
  VehicleType? vehicleType;
  String brand;
  String model;
  String plate;

  double? lat;
  double? lng;
  DateTime? lastLocationAt;

  Driver({
    this.active = false,
    this.id = "",
    this.link = "",
    this.brand = "",
    this.model = "",
    this.plate = "",
    this.basePrice,
  });

  Driver.fromJSON(Map<String, dynamic> jsonMap)
      : active = jsonMap['active'] == true || jsonMap['active'] == '1',
        id = jsonMap['id']?.toString() ?? '',
        link = jsonMap['link'] ?? '',
        user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : null,
        basePrice = jsonMap['base_price'] != null
            ? double.parse(jsonMap['base_price'])
            : null,
        baseDistance = jsonMap['base_distance'] != null
            ? double.parse(jsonMap['base_distance'])
            : null,
        additionalDistancePricing =
            jsonMap['additional_distance_pricing'] != null
                ? double.parse(jsonMap['additional_distance_pricing'])
                : null,
        vehicleType = jsonMap['vehicle_type'] != null
            ? VehicleType.fromJSON(jsonMap['vehicle_type'])
            : null,
        brand = jsonMap['brand'] ?? '',
        model = jsonMap['model'] ?? '',
        plate = jsonMap['plate'] ?? '',
        lat = jsonMap['lat'] != null ? double.parse(jsonMap['lat']) : null,
        lng = jsonMap['lng'] != null ? double.parse(jsonMap['lng']) : null,
        lastLocationAt = jsonMap['last_location_at'] != null
            ? DateTime.tryParse(jsonMap['last_location_at']) ?? null
            : null;

  Map<String, String> toJSON() {
    Map<String, String> json = {};
    json = {
      'id': id,
      'active': active ? '1' : '0',
    };
    return json;
  }
}
