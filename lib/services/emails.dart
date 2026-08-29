import 'package:mailmind/models/email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/models/emails.dart';
import 'package:mailmind/services/api.dart';

final emailsProivder = FutureProvider<List<EMAILS>>((ref) async {
  return [];
}, retry: (retryCount, error) {});

final emailProivder = FutureProvider<EMAIL?>((ref) async {
  return null;
}, retry: (retryCount, error) {});

Future<cursorData> getUserEmails() async {
  Map<String, Object?> data = await getUserEmailsApi();
  return cursorData.formJson(data);
}

void overrideValue(bool add, List<EMAILS> newData, List<EMAILS>? oldData) {
  if (add == true && oldData != null) {
    List<EMAILS> emails = oldData;
    newData.forEach((email) {
      emails.add(email);
    });

    emailsProivder.overrideWithValue(AsyncValue.data(emails));
  } else {
    emailsProivder.overrideWithValue(AsyncValue.data(newData));
  }
}

class cursorData {
  String cursor;
  bool hasMore;
  List<EMAILS> emails = [];

  cursorData({
    required this.cursor,
    required this.hasMore,
    required List<Map<String, Object?>> emails,
  }) {
    emails.forEach((email) {
      EMAILS newEmail = EMAILS.fromJson(email);
      this.emails.add(newEmail);
    });
  }

  factory cursorData.formJson(Map<String, Object?> json) {
    return cursorData(
      cursor: json['cursor'] as String,
      hasMore: json['hasMore'] as bool,
      emails: json['emails'] as List<Map<String, Object?>>,
    );
  }
}
