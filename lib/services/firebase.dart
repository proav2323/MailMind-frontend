import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

FirebaseApp? app = null;
FirebaseMessaging? msg = null;

Future<void> initFirebaseApp() async {
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void intilaizeMsg() {
  msg = FirebaseMessaging.instance;

  log("intaizing msg");
}

void getToken() {
  if (msg != null) {
    msg!.getToken().then(
      (value) => {
        if (value != null) {log(value)},
      },
    );
  }
}

Future<String?> getFirebaseInstallationId() async {
  try {
    String fid = await FirebaseInstallations.instance.getId();
    return fid;
  } catch (e) {
    log("Error fetching FID: $e");
    return null;
  }
}
