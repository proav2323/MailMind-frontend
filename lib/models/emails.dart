import 'package:mailmind/models/attachments.dart';
import 'package:mailmind/models/user.dart';

class EMAIL {
  final String id;
  final String gmailId;
  final String subject;
  final String sender;
  final String summary;
  final String gmailSubject;
  final String priority;
  final String aiPriority;
  final String category;
  DateTime? deadline;
  DateTime receivedAt;
  DateTime? lastOpenedAt;
  bool isRead;
  final bool isStarred;
  final bool isCompleted;
  final bool requiresAction;
  final List<Map> bodyInOrder;
  List<ATTACHMENTS> attachments = [];

  EMAIL({
    required this.id,
    required this.gmailId,
    required this.sender,
    required this.subject,
    required this.summary,
    required this.category,
    required this.priority,
    required this.isRead,
    required this.deadline,
    required this.receivedAt,
    required this.aiPriority,
    required this.bodyInOrder,
    required this.gmailSubject,
    required this.isCompleted,
    required this.isStarred,
    required this.lastOpenedAt,
    required this.requiresAction,
    required List<Map> attachments,
  }) {
    attachments.forEach((attachment) {
      ATTACHMENTS newAttachmant = ATTACHMENTS(
        attachmentId: attachment['attachmentId'],
        file: attachment['file'],
        mimetype: attachment['mimetype'],
      );

      this.attachments.add(newAttachmant);
    });
  }

  factory EMAIL.fromJson(Map<String, Object?> json) {
    return EMAIL(
      id: json['id'] as String,
      gmailId: json['gmailId'] as String,
      sender: json['sender'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      isRead: json['isRead'] as bool,
      deadline: json['deadline'] == null || json['deadline'] == 'null'
          ? null
          : DateTime.parse(json['deadline'].toString()),
      receivedAt: DateTime.parse(json['receivedAt'].toString()),
      priority: json['priority'] as String,
      subject: json['subject'] as String,
      aiPriority: json['aiPriority'] as String,
      attachments: json['attachments'] as List<Map>,
      bodyInOrder: json['bodyInOrder'] as List<Map>,
      gmailSubject: json['gmailSubject'] as String,
      isCompleted: json['isCompleted'] as bool,
      isStarred: json['isStarred'] as bool,
      lastOpenedAt:
          json['lastOpenedAt'] == null || json['lastOpenedAt'] == 'null'
          ? null
          : DateTime.parse(json['lastOpenedAt'].toString()),
      requiresAction: json['requiresAction'] as bool,
    );
  }
}
