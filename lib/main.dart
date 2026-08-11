import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/components/socketLifeCycle.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebaseApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  intilaizeMsg();
  if (msg != null) {
    await msg!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    getToken();
  }
  runApp(ProviderScope(child: MyApp()));
  await initApi();
  await initGoogle();
}

// GoRouter configuration

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SocketLifecycleManager();
  }
}
