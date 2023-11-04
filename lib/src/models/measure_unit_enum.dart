import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum MeasureUnitEnum { mile, kilometer }

class MeasureUnitEnumHelper {
  static MeasureUnitEnum enumFromString(String? enumString) {
    switch (enumString) {
      case 'km':
        return MeasureUnitEnum.kilometer;
      case 'mi':
        return MeasureUnitEnum.mile;
      default:
        return MeasureUnitEnum.kilometer;
    }
  }

  static String abbreviation(
      MeasureUnitEnum measureUnitEnum, BuildContext context) {
    switch (measureUnitEnum) {
      case MeasureUnitEnum.kilometer:
        return AppLocalizations.of(context)!.km;
      case MeasureUnitEnum.mile:
        return AppLocalizations.of(context)!.mi;
      default:
        return '-';
    }
  }

  static String description(
      MeasureUnitEnum measureUnitEnum, BuildContext context) {
    switch (measureUnitEnum) {
      case MeasureUnitEnum.kilometer:
        return AppLocalizations.of(context)!.kilometer;
      case MeasureUnitEnum.mile:
        return AppLocalizations.of(context)!.mile;
      default:
        return '-';
    }
  }
}
