import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/components/socketLifeCycle.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/services/auth.dart';
import 'package:mailmind/services/firebase.dart';

void main() async {
  runApp(ProviderScope(child: MyApp()));
  await initApi();
  await initGoogle();
  await initFirebaseApp();
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
