import 'package:place_picker/place_picker.dart';

class CreateRideAddress {
  String? number;
  late LocationResult address;

  CreateRideAddress(this.address, {this.number});

  CreateRideAddress.fromJSON(Map<String, dynamic> jsonMap) {
    number = jsonMap['number'] != null && jsonMap['number'] != ""
        ? jsonMap['number']
        : null;
    address = LocationResult();
    address.city?.name = jsonMap['city'];
    address.country?.name = jsonMap['country'];
    address.placeId = jsonMap['place_id'];
    address.name = jsonMap['name'];
    address.formattedAddress = jsonMap['formatted_address'];
    if (jsonMap['geometry']['location']['lat'] != null &&
        jsonMap['geometry']['location']['lng'] != null) {
      address.latLng = LatLng(jsonMap['geometry']['location']['lat'],
          jsonMap['geometry']['location']['lng']);
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {};
    json['formatted_address'] = address.formattedAddress;
    json['geometry'] = {};
    json['geometry']['location'] = {};
    json['geometry']['location']['lat'] = address.latLng?.latitude ?? 0;
    json['geometry']['location']['lng'] = address.latLng?.longitude ?? 0;
    json['country'] = address.country?.name;
    json['name'] = address.name;
    json['city'] = address.city?.name;
    json['place_id'] = address.placeId;
    json['number'] = number ?? '';

    return json;
  }
}
