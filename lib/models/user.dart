import 'package:MailMind/models/emails.dart';
import 'package:MailMind/models/notifications.dart';
import 'package:flutter/material.dart';

class USER {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String college;
  final String branch;
  final int year;
  final String oAuthProvider;
  final DateTime created_at;
  final DateTime updated_at;
  final List<EMAIL> Emails;
  final List<NOTIFICATIONS> notifications;

  USER({
    required this.name,
    required this.email,
    required this.branch,
    required this.college,
    required this.oAuthProvider,
    required this.photoUrl,
    required this.year,
    required this.id,
    required this.updated_at,
    required this.created_at,
    required this.Emails,
    required this.notifications,
  }) {}

  factory USER.fromJson(Map<String, Object?> json) {
    return USER(
      name: json['name'] as String,
      email: json['email'] as String,
      branch: json['branch'] as String,
      college: json['college'] as String,
      oAuthProvider: json['oAuthProvider'] as String,
      photoUrl: json['photoUrl'] as String,
      year: json['year'] as int,
      id: json['id'] as String,
      updated_at: json['updated_at'] as DateTime,
      created_at: json['created_at'] as DateTime,
      Emails: json['emails'] as List<EMAIL>,
      notifications: json['notifications'] as List<NOTIFICATIONS>,
    );
  }
}
