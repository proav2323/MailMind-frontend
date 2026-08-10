import 'package:mailmind/models/user.dart';

class EMAIL {
  final String id;
  final String userId;
  final String gmailId;
  final String subject;
  final String sender;
  final String summary;
  final String priority;
  final Map body;
  final String category;
  DateTime? deadline;
  DateTime receivedAt;
  bool isRead;
  USER? User;

  EMAIL({
    required this.id,
    required this.userId,
    required this.gmailId,
    required this.sender,
    required this.subject,
    required this.summary,
    required this.body,
    required this.category,
    required this.priority,
    required this.isRead,
    required this.deadline,
    required this.receivedAt,
    required User,
  }) {
    // Map<String, dynamic> data = {
    //   "emails": [],
    //   "notifications": [],
    //   "id": User['id'],
    //   "name": User['name'],
    //   "email": User['email'],
    //   "branch": null,
    //   "college": null,
    //   "oAuthProvider": User['oAuthProvider'],
    //   "photoUrl": User['photoUrl'],
    //   "year": null,
    //   "updated_at": User['updated_at'],
    //   "created_at": User['created_at'],
    // };
    this.User = null;
  }

  factory EMAIL.fromJson(Map<String, Object?> json) {
    return EMAIL(
      userId: json['userId'] as String,
      id: json['id'] as String,
      gmailId: json['gmailId'] as String,
      sender: json['sender'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      isRead: json['isRead'] as bool,
      body: json['body'] as Map,
      deadline: json['deadline'] == null || json['deadline'] == 'null'
          ? null
          : DateTime.parse(json['deadline'].toString()),
      receivedAt: DateTime.parse(json['receivedAt'].toString()),
      User: null,
      priority: json['priority'] as String,
      subject: json['subject'] as String,
    );
  }
}
