import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum PaymentGatewayEnum { paypal, stripe, mercado_pago, flutterwave, razorpay, online }

class PaymentGatewayEnumHelper {
  static PaymentGatewayEnum? enumFromString(String? enumString) {
    switch (enumString) {
      case 'paypal':
      case 'PayPal':
        return PaymentGatewayEnum.paypal;
      case 'stripe':
        return PaymentGatewayEnum.stripe;       
      case 'flutterwave':
        return PaymentGatewayEnum.flutterwave;
      case 'mercado_pago':
        return PaymentGatewayEnum.mercado_pago;
      case 'razorpay':
        return PaymentGatewayEnum.razorpay;
      default:
        return null;
    }
  }

  static String description(
      PaymentGatewayEnum paymentGatewayEnum, BuildContext context) {
    switch (paymentGatewayEnum) {
      case PaymentGatewayEnum.paypal:
        return 'PayPal';
      case PaymentGatewayEnum.stripe:
        return 'Stripe';
      case PaymentGatewayEnum.flutterwave:
        return 'Flutterwave';
      case PaymentGatewayEnum.mercado_pago:
        return 'Mercado Pago';
      case PaymentGatewayEnum.razorpay:
        return 'Razorpay';
      default:
        return AppLocalizations.of(context)!.online;
    }
  }
}
