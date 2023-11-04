import '../models/user.dart';
import '../models/media.dart';

class Message {
  String id;
  String rideId;
  String? message;
  Media? media;
  User sender;
  DateTime createdAt;

  Message(this.id, this.rideId, this.message, this.media, this.sender,
      this.createdAt);

  Message.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        rideId = jsonMap['ride_id']?.toString() ?? '',
        message = jsonMap['message'],
        media = (jsonMap['has_media'] ?? false)
            ? Media.fromJSON(jsonMap['media'][0])
            : null,
        sender = User.fromJSON(jsonMap['sender']),
        createdAt = jsonMap['created_at'] != null
            ? DateTime.parse(jsonMap['created_at'])
            : DateTime.now();
}
