import 'package:mailmind/models/user.dart';

class NOTIFICATIONS {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final bool isSent;
  USER? User;

  NOTIFICATIONS({
    required dynamic User,
    required this.id,
    required this.body,
    required this.isSent,
    required this.scheduledTime,
    required this.title,
    required this.userId,
  }) {
    Map<String, dynamic> data = {
      "emails": [],
      "notifications": [],
      "id": User['id'],
      "name": User['name'],
      "email": User['email'],
      "branch": null,
      "college": null,
      "oAuthProvider": User['oAuthProvider'],
      "photoUrl": User['photoUrl'],
      "year": null,
      "updated_at": User['updated_at'],
      "created_at": User['created_at'],
    };
    this.User = USER.fromJson(data);
  }

  factory NOTIFICATIONS.fromJson(Map<String, Object?> json) {
    return NOTIFICATIONS(
      userId: json['userId'] as String,
      id: json['id'] as String,
      isSent: json['isSent'] as bool,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'].toString()),
      User: json['User'],
    );
  }
}
