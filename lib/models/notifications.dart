import 'package:MailMind/models/user.dart';

class NOTIFICATIONS {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final bool isSent;
  final USER User;

  NOTIFICATIONS({
    required this.User,
    required this.id,
    required this.body,
    required this.isSent,
    required this.scheduledTime,
    required this.title,
    required this.userId,
  });

  factory NOTIFICATIONS.fromJson(Map<String, Object?> json) {
    return NOTIFICATIONS(
      userId: json['userId'] as String,
      id: json['id'] as String,
      isSent: json['isSent'] as bool,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'].toString()),
      User: json['User'] as USER,
    );
  }
}
