import 'package:mailmind/models/user.dart';

class EMAILS {
  final String id;
  final String gmailId;
  final String subject;
  final String sender;
  final String summary;
  final String priority;
  final String aiPriority;
  final bool isStarred;
  final String category;
  DateTime receivedAt;
  bool isRead;

  EMAILS({
    required this.id,
    required this.gmailId,
    required this.sender,
    required this.subject,
    required this.summary,
    required this.category,
    required this.priority,
    required this.isRead,
    required this.receivedAt,
    required this.aiPriority,
    required this.isStarred,
  }) {}

  factory EMAILS.fromJson(Map<String, Object?> json) {
    return EMAILS(
      id: json['id'] as String,
      gmailId: json['gmailId'] as String,
      sender: json['sender'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      isRead: json['isRead'] as bool,
      receivedAt: DateTime.parse(json['receivedAt'].toString()),
      priority: json['priority'] as String,
      subject: json['subject'] as String,
      aiPriority: json['aiPriority'] as String,
      isStarred: json['isStarred'] as bool,
    );
  }
}
