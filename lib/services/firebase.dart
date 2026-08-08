import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

FirebaseApp? app = null;

Future<void> initFirebaseApp() async {
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
