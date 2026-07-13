import 'package:MailMind/services/api.dart';
import 'package:MailMind/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MailMind/pages/home.dart';
import 'package:go_router/go_router.dart';
import 'package:MailMind/pages/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  if (kReleaseMode == false) {
    await dotenv.load(fileName: '.env');
  }
  runApp(ProviderScope(child: MyApp()));
  await initApi();
}

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => MyHomePage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MailMind',
      themeMode: ThemeMode.system,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
