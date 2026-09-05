import 'dart:developer';

import 'package:mailmind/models/email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/models/emails.dart';
import 'package:mailmind/services/api.dart';

final emailsProivder = NotifierProvider(emailsNotifier.new);

final emailProivder = FutureProvider<EMAIL?>((ref) async {
  return null;
}, retry: (retryCount, error) {});

final cursorProvider = NotifierProvider(cursorNotifier.new);

final hasMoreProvider = NotifierProvider(hasMoreNotifier.new);

Future<cursorData> getUserEmails(String? cursor) async {
  Map<String, Object?> data = await getUserEmailsApi(cursor);
  return cursorData.formJson(data);
}

Future<cursorData> getUserFilteredEmails(
  String? starred,
  String? category,
  String? priority,
  String? dateStart,
  String? dateEnd,
  String? cursor,
) async {
  Map<String, Object?> data = await getUserFilteredEmailsApi(
    starred,
    category,
    priority,
    dateStart,
    dateEnd,
    cursor,
  );
  return cursorData.formJson(data);
}

class emailsNotifier extends Notifier<List<EMAILS>> {
  @override
  List<EMAILS> build() => []; // Initial value

  // Method to change value after it initializes

  void updateValue(bool add, List<EMAILS> newData) {
    if (add == true) {
      List<EMAILS> emails = state;
      newData.forEach((email) {
        if (!emails.any((e) => e.id == email.id)) {
          emails.add(email);
        }
      });
      state = emails;
    } else {
      state = newData;
    }
  }

  List<EMAILS> getValue() {
    return state;
  }
}

class hasMoreNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Initial value

  // Method to change value after it initializes
  void updateValue(bool newValue) {
    state = newValue;
  }

  bool getValue() {
    return state;
  }
}

class cursorNotifier extends Notifier<String?> {
  @override
  String? build() => null; // Initial value

  // Method to change value after it initializes
  void updateValue(String? newValue) {
    state = newValue;
  }

  String? getValue() {
    return state;
  }
}

class cursorData {
  String? cursor;
  bool hasMore;
  List<EMAILS> emails = [];

  cursorData({
    required this.cursor,
    required this.hasMore,
    required List<dynamic> emails,
  }) {
    emails.forEach((email) {
      EMAILS newEmail = EMAILS.fromJson(email);
      this.emails.add(newEmail);
    });
  }

  factory cursorData.formJson(Map<String, Object?> json) {
    log(json['hasMore'].toString());
    return cursorData(
      cursor: json['nextCursor'] as String?,
      hasMore: bool.parse(json['hasMore'].toString()),
      emails: json['emails'] as List<dynamic>,
    );
  }
}
