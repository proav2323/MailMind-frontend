import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/components/socketLifeCycle.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseSetup FS = new FirebaseSetup();
  await FS.init();
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
