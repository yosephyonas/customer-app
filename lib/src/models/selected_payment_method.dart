import 'offline_payment_method.dart';

class SelectedPaymentMethod {
  String id;
  String name;
  OfflinePaymentMethod? offlinePaymentMethod;
  PaymentTypeEnum paymentType;

  SelectedPaymentMethod(
    this.paymentType, {
    this.id = "",
    this.name = "",
    this.offlinePaymentMethod,
  });

  Map<String, String> toJSON() {
    return {
      'id': id,
      'name': name,
    };
  }
}

enum PaymentTypeEnum {
  offline,
  online,
}
