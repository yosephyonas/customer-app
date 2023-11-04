import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:driver_customer_app/src/models/driver.dart';

import '../models/status_enum.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../helper/custom_trace.dart';
import '../helper/helper.dart';
import '../models/create_ride_address.dart';
import '../models/nearby_driver.dart';
import '../models/ride.dart';
import '../models/ride_simulation.dart';
import '../models/selected_payment_method.dart';
import '../models/vehicle_type.dart';

Future<List<NearbyDriver>> findNearBy(
    CreateRideAddress location, VehicleType vehicleType) async {
  final collectJson;
  Map<String, dynamic> dataCollect = {};
  dataCollect['geometry'] = {};
  dataCollect['geometry']['location'] = {};
  dataCollect['geometry']['location']['lat'] =
      location.address.latLng?.latitude ?? 0;
  dataCollect['geometry']['location']['lng'] =
      location.address.latLng?.longitude ?? 0;
  collectJson = jsonEncode(dataCollect);

  var response = await http
      .post(Helper.getUri('driver/findNearBy'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "boarding_address_data": collectJson,
            "vehicle_type_id": vehicleType.id,
          }))
      .timeout(const Duration(seconds: 15));
  print(response.body);
  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']
        .map((driver) => NearbyDriver.fromJSON(driver))
        .toList()
        .cast<NearbyDriver>();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<List<Driver>> getDriversAround(double lat, double lng) async {
  Map<String, String> queryParameters = {
    "lat": lat.toString(),
    "lng": lng.toString(),
  };
  var response = await http.get(
    Helper.getUri('drivers', addApiToken: false, queryParam: queryParameters),
    headers: <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  ).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']
        .map((driver) => Driver.fromJSON(driver))
        .toList()
        .cast<Driver>();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<RideSimulation> simulate(CreateRideAddress pickup,
    CreateRideAddress ride, VehicleType vehicleType) async {
  var response = await http
      .post(Helper.getUri('rides/simulate'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "boarding_address_data": jsonEncode(pickup.toJSON()),
            "destination_address_data": jsonEncode(ride.toJSON()),
            "vehicle_type": vehicleType.id,
          }))
      .timeout(const Duration(seconds: 15));
  print('response ${response.body}');
  if (response.statusCode == HttpStatus.ok) {
    return RideSimulation.fromJSON(json.decode(response.body));
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<String> submit(
    CreateRideAddress pickup,
    CreateRideAddress ride,
    VehicleType vehicleType,
    SelectedPaymentMethod paymentMethod,
    String? observation) async {
  Map<String, dynamic> body = {
    "boarding_address_data": jsonEncode(pickup.toJSON()),
    "boarding_location": pickup.address.formattedAddress,
    "destination_address_data": jsonEncode(ride.toJSON()),
    "vehicle_type": vehicleType.id,
    'observation': observation,
    "payment_method_type": paymentMethod.paymentType.name,
    "payment_method": paymentMethod.id,
  };

  var response = await http
      .post(Helper.getUri('rides'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return json.decode(response.body)['id'].toString();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Map<String, dynamic>> getRides(
    {int? pageSize,
    int currentItem = 0,
    DateTime? dateTimeStart,
    DateTime? dateTimeEnd}) async {
  Map<String, String> queryParameters = {};
  if (pageSize != null) {
    queryParameters.addAll(
        {'limit': pageSize.toString(), 'current_item': currentItem.toString()});
  }
  if (dateTimeStart != null) {
    queryParameters.addAll({
      'datetime_start': dateTimeStart.toString(),
    });
  }
  if (dateTimeEnd != null) {
    queryParameters.addAll({'datetime_end': dateTimeEnd.toString()});
  }
  var response = await http.get(
      Helper.getUri('rides', queryParam: queryParameters),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    List<Ride> rides = jsonDecode(response.body)['data']['rides']
        .map((ride) => Ride.fromJSON(ride))
        .toList()
        .cast<Ride>();
    bool hasMoreRides = jsonDecode(response.body)['data']['has_more_rides'];

    return {'hasMoreRides': hasMoreRides, 'rides': rides};
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Ride> getRide(String rideId) async {
  var response =
      await http.get(Helper.getUri('rides/$rideId'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return Ride.fromJSON(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Map<String, dynamic>> initializePayment(Ride ride) async {
  var response = await http
      .post(Helper.getUri('rides/initializePayment'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'ride_id': ride.id}))
      .timeout(const Duration(seconds: 15));
  log(response.body);
  if (response.statusCode == HttpStatus.ok) {
    return json.decode(response.body);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<void> cancelRide(Ride ride) async {
  var response = await http
      .post(Helper.getUri('rides/cancel'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'ride_id': ride.id}))
      .timeout(const Duration(seconds: 15));
  final jsonReponse = json.decode(response.body);
  if (response.statusCode != HttpStatus.ok || jsonReponse['success'] != 1) {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<StatusEnum?> checkPaymentStatus(Ride ride) async {
  var response = await http.get(
    Helper.getUri('rides/${ride.id}/checkPaymentByRideID'),
    headers: <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  ).timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return StatusEnumHelper.enumFromString(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<LatLng> updateDriverLocation(Ride ride) async {
  var response = await http
      .post(
        Helper.getUri('rides/getDriverPosition'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'ride_id': ride.id}),
      )
      .timeout(const Duration(seconds: 15));

  final jsonReponse = json.decode(response.body);
  if (response.statusCode == HttpStatus.ok && jsonReponse['success'] == 1) {
    return LatLng(jsonReponse['lat'], jsonReponse['lng']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<StatusEnum?> checkRideStatus(Ride ride) async {
  var response = await http
      .get(Helper.getUri('rides/${ride.id}/status'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return StatusEnumHelper.enumFromString(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}
