import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StatusEnum {
  pending,
  paid,
  waiting,
  accepted,
  in_progress,
  cancelled,
  completed,
}

class StatusEnumHelper {
  static StatusEnum? enumFromString(String enumString) {
    switch (enumString) {
      case 'pending':
        return StatusEnum.pending;
      case 'paid':
        return StatusEnum.paid;
      case 'waiting':
        return StatusEnum.waiting;
      case 'accepted':
        return StatusEnum.accepted;
      case 'in_progress':
        return StatusEnum.in_progress;
      case 'cancelled':
        return StatusEnum.cancelled;
      case 'completed':
        return StatusEnum.completed;
      default:
        return null;
    }
  }

  static String description(StatusEnum? statusEnum, BuildContext context) {
    switch (statusEnum) {
      case StatusEnum.pending:
        return AppLocalizations.of(context)!.pending;
      case StatusEnum.paid:
        return AppLocalizations.of(context)!.paid;
      case StatusEnum.waiting:
        return AppLocalizations.of(context)!.waiting;
      case StatusEnum.accepted:
        return AppLocalizations.of(context)!.accepted;
      case StatusEnum.in_progress:
        return AppLocalizations.of(context)!.inProgress;
      case StatusEnum.cancelled:
        return AppLocalizations.of(context)!.cancelled;
      case StatusEnum.completed:
        return AppLocalizations.of(context)!.completed;
      default:
        return '-';
    }
  }
}

extension StatusEnumExtension on StatusEnum {
  String get originalName {
    switch (this) {
      case StatusEnum.pending:
        return 'pending';
      case StatusEnum.paid:
        return 'paid';
      case StatusEnum.waiting:
        return 'waiting';
      case StatusEnum.accepted:
        return 'accepted';
      case StatusEnum.in_progress:
        return 'in_progress';
      case StatusEnum.cancelled:
        return 'cancelled';
      case StatusEnum.completed:
        return 'completed';
    }
  }
}
