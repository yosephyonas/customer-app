import 'package:adaptive_theme/adaptive_theme.dart';
import '../models/measure_unit_enum.dart';
import 'package:flutter/material.dart';

import 'offline_payment_method.dart';
import 'vehicle_type.dart';

class Setting {
  String appName;
  Color? mainColor;
  Color? secondaryColor;
  Color? highlightColor;
  Color? backgroundColor;
  Color? mainColorDark;
  Color? secondaryColorDark;
  Color? highlightColorDark;
  Color? backgroundColorDark;
  MeasureUnitEnum measureUnit;
  AdaptiveThemeMode theme;
  String? googleMapsKey;
  bool enableTermsOfService;
  String termsOfService;
  bool enablePrivacyPolicy;
  String privacyPolicy;
  String currency;
  bool allowCustomRideValues;
  bool facebookEnabled = false;
  bool googleEnabled = false;
  bool twitterEnabled = false;
  bool mercadoPagoEnabled = false;
  bool paypalEnabled = false;
  bool stripeEnabled = false;
  String? stripeKey;
  bool flutterwaveEnabled = false;
  String? flutterwaveKey;
  bool razorpayEnabled = false;
  Locale locale;
  List<OfflinePaymentMethod> offlinePaymentMethods = [];
  List<VehicleType> vehicleTypes;

  Setting({
    this.appName = '',
    this.measureUnit = MeasureUnitEnum.kilometer,
    this.theme = AdaptiveThemeMode.light,
    this.enableTermsOfService = false,
    this.termsOfService = '',
    this.enablePrivacyPolicy = false,
    this.privacyPolicy = '',
    this.currency = '',
    this.allowCustomRideValues = true,
    this.facebookEnabled = false,
    this.googleEnabled = false,
    this.twitterEnabled = false,
    this.stripeEnabled = false,
    this.flutterwaveEnabled = false,
    this.razorpayEnabled = false,
    this.locale = const Locale('en'),
    this.vehicleTypes = const [],
  });

  Setting.fromJSON(Map<String, dynamic> jsonMap)
      : appName = jsonMap['app_name'] ?? '',
        mainColor = jsonMap['main_color'] != null && jsonMap['main_color'] != ''
            ? Color(int.parse(jsonMap['main_color'].replaceAll('#', '0xff')))
            : null,
        secondaryColor = jsonMap['secondary_color'] != null &&
                jsonMap['secondary_color'] != ''
            ? Color(
                int.parse(jsonMap['secondary_color'].replaceAll('#', '0xff')))
            : null,
        highlightColor = jsonMap['highlight_color'] != null &&
                jsonMap['highlight_color'] != ''
            ? Color(
                int.parse(jsonMap['highlight_color'].replaceAll('#', '0xff')))
            : null,
        backgroundColor = jsonMap['background_color'] != null &&
                jsonMap['background_color'] != ''
            ? Color(
                int.parse(jsonMap['background_color'].replaceAll('#', '0xff')))
            : null,
        mainColorDark = jsonMap['main_color_dark_theme'] != null &&
                jsonMap['main_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['main_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        secondaryColorDark = jsonMap['secondary_color_dark_theme'] != null &&
                jsonMap['secondary_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['secondary_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        highlightColorDark = jsonMap['highlight_color_dark_theme'] != null &&
                jsonMap['highlight_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['highlight_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        backgroundColorDark = jsonMap['background_color_dark_theme'] != null &&
                jsonMap['background_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['background_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        measureUnit =
            MeasureUnitEnumHelper.enumFromString(jsonMap['measure_unit']),
        theme = AdaptiveThemeMode.light,
        locale = Locale(
          jsonMap['locale'] ?? 'en',
          jsonMap['locale_region'],
        ),
        enableTermsOfService = jsonMap['enable_terms_of_service'] == true ||
            jsonMap['enable_terms_of_service'] == "1",
        termsOfService = jsonMap['terms_of_service'] ?? '',
        enablePrivacyPolicy = jsonMap['enable_privacy_policy'] == true ||
            jsonMap['enable_privacy_policy'] == "1",
        privacyPolicy = jsonMap['privacy_policy'] ?? '',
        currency = jsonMap['currency'] ?? 'USD',
        allowCustomRideValues = jsonMap['allow_custom_ride_values'] == true ||
            jsonMap['allow_custom_ride_values'] == "1",
        googleMapsKey = jsonMap['google_maps_key'],
        facebookEnabled = jsonMap['enable_facebook'] == true ||
            jsonMap['enable_facebook'] == "1",
        googleEnabled =
            jsonMap['enable_google'] == true || jsonMap['enable_google'] == "1",
        twitterEnabled = jsonMap['enable_twitter'] == true ||
            jsonMap['enable_twitter'] == "1",
        stripeKey = jsonMap['stripe_key'],
        stripeEnabled =
            jsonMap['enable_stripe'] == true || jsonMap['enable_stripe'] == "1",
        flutterwaveKey = jsonMap['flutterwave_key'],
        flutterwaveEnabled = jsonMap['enable_flutterwave'] == true ||
            jsonMap['enable_flutterwave'] == "1",
        mercadoPagoEnabled = jsonMap['enable_mercado_pago'] == true ||
            jsonMap['enable_mercado_pago'] == "1",
        paypalEnabled =
            jsonMap['enable_paypal'] == true || jsonMap['enable_paypal'] == "1",
        offlinePaymentMethods = jsonMap['offline_payment_methods'] != null
            ? List<OfflinePaymentMethod>.from(jsonMap['offline_payment_methods']
                .map((paymentMethod) =>
                    OfflinePaymentMethod.fromJSON(paymentMethod)))
            : [],
        vehicleTypes = jsonMap['vehicle_types'] != null
            ? jsonMap['vehicle_types']
                    .map((address) => VehicleType.fromJSON(address))
                    .toList()
                    .cast<VehicleType>() ??
                []
            : [],
        razorpayEnabled = jsonMap['enable_razorpay'] == true ||
            jsonMap['enable_razorpay'] == "1";

  Map<String, dynamic> toJSON() {
    return {
      'termos_entregador': termsOfService,
    };
  }
}
