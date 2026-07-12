import 'package:MailMind/models/user.dart';

class EMAIL {
  final String id;
  final String userId;
  final String gmailId;
  final String subject;
  final String sender;
  final String summary;
  final String priority;
  final String body;
  final String category;
  DateTime deadline;
  DateTime receivedAt;
  bool isRead;
  USER User;

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
    required this.User,
  }) {}

  factory EMAIL.fromJson(Map<String, Object?> json) {
    return EMAIL(
      userId: json['userId'] as String,
      id: json['id'] as String,
      gmailId: json['gamilId'] as String,
      sender: json['sender'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      isRead: json['isRead'] as bool,
      body: json['body'] as String,
      deadline: json['deadline'] as DateTime,
      receivedAt: json['receivedAt'] as DateTime,
      User: json['User'] as USER,
      priority: json['priority'] as String,
      subject: json['subject'] as String,
    );
  }
}
