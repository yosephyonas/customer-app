import 'status_enum.dart';

class Status {
  StatusEnum status;
  DateTime? data;

  Status({
    this.status = StatusEnum.accepted,
  });

  Status.fromJSON(Map<String, dynamic> jsonMap)
      : status = jsonMap['status'] != null
            ? StatusEnumHelper.enumFromString(jsonMap['status']) ??
                StatusEnum.accepted
            : StatusEnum.accepted,
        data = jsonMap['data'] != null
            ? DateTime.tryParse(jsonMap['data']) ?? null
            : null;

  Map<String, dynamic> toJSON() {
    return {'status': status, 'data': data.toString()};
  }
}
