import 'dart:convert';

import 'address.dart';
import 'driver.dart';
import 'offline_payment_method.dart';
import 'payment_gateway_enum.dart';
import 'status_enum.dart';
import 'vehicle_type.dart';

class Ride {
  String id;
  Driver? driver;
  Address? boardingLocation;
  Address? destinationLocation;
  VehicleType? vehicleType;
  StatusEnum? rideStatus;
  StatusEnum? paymentStatus;
  PaymentGatewayEnum? paymentGateway;
  OfflinePaymentMethod? offlinePaymentMethod;
  String? observation;
  double distance;
  double amount;
  double driverValue;
  double appValue;
  bool finalized;
  DateTime? createdAt;
  DateTime? rideStatusDate;

  Ride({
    this.id = "",
    this.observation = "",
    this.distance = 0.00,
    this.amount = 0.00,
    this.driverValue = 0.00,
    this.appValue = 0.00,
    this.finalized = false,
    this.paymentGateway = PaymentGatewayEnum.online,
  });

  Ride.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        driver = jsonMap['driver'] != null
            ? Driver.fromJSON(jsonMap['driver'])
            : null,
        boardingLocation = jsonMap['boarding_location_data'] != null
            ? Address.fromJSON(jsonDecode(jsonMap['boarding_location_data']))
            : null,
        destinationLocation = jsonMap['destination_location_data'] != null
            ? Address.fromJSON(jsonDecode(jsonMap['destination_location_data']))
            : null,
        vehicleType = jsonMap['vehicle_type'] != null
            ? VehicleType.fromJSON(jsonMap['vehicle_type'])
            : null,
        rideStatus = jsonMap['ride_status'] != null
            ? StatusEnumHelper.enumFromString(jsonMap['ride_status'])
            : null,
        paymentStatus = jsonMap['payment_status'] != null
            ? StatusEnumHelper.enumFromString(jsonMap['payment_status']) ??
                StatusEnum.pending
            : StatusEnum.pending,
        paymentGateway =
            PaymentGatewayEnumHelper.enumFromString(jsonMap['payment_gateway']),
        offlinePaymentMethod = jsonMap['offline_payment_method'] != null
            ? OfflinePaymentMethod.fromJSON(jsonMap['offline_payment_method'])
            : null,
        observation = jsonMap['status_observation'] != null
            ? jsonMap['status_observation']
            : null,
        distance = jsonMap['distance'] != null
            ? double.parse(jsonMap['distance'].toString())
            : 0.00,
        amount = jsonMap['total_value'] != null
            ? double.parse(jsonMap['total_value'].toString())
            : 0.00,
        driverValue = jsonMap['driver_value'] != null
            ? double.parse(jsonMap['driver_value'].toString())
            : 0.00,
        appValue = jsonMap['app_value'] != null
            ? double.parse(jsonMap['app_value'].toString())
            : 0.00,
        finalized = StatusEnumHelper.enumFromString(jsonMap['ride_status']) ==
                StatusEnum.completed ||
            StatusEnumHelper.enumFromString(jsonMap['ride_status']) ==
                StatusEnum.cancelled,
        createdAt = jsonMap['created_at'] != null
            ? DateTime.tryParse(jsonMap['created_at']) ?? null
            : null,
        rideStatusDate = jsonMap['ride_status_date'] != null
            ? DateTime.tryParse(jsonMap['ride_status_date']) ?? null
            : null;

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'driver': driver?.toJSON(),
      'distance': distance,
      'observacao': observation,
      'valor_total': amount,
      'finalizado': finalized,
    };
  }
}
