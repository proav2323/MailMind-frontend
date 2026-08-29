class ATTACHMENTS {
  final String attachmentId;
  final String mimetype;
  final String file;

  ATTACHMENTS({
    required this.attachmentId,
    required this.file,
    required this.mimetype,
  }) {}

  factory ATTACHMENTS.fromJson(Map<String, Object?> json) {
    return ATTACHMENTS(
      file: json['file'] as String,
      attachmentId: json['attachmentId'] as String,
      mimetype: json['mimetype'] as String,
    );
  }
}
