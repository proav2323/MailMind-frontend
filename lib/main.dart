import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/pages/login.dart';
import 'package:mailmind/services/api.dart';
import 'package:mailmind/pages/home.dart';
import 'package:mailmind/services/auth.dart';

void main() async {
  if (kIsWeb || Platform.isWindows) {}
  runApp(ProviderScope(child: MyApp()));
  await initApi();
  await initGoogle();
}

// GoRouter configuration
final _router = GoRouter(
  initialLocation: '/',
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
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF212121), // Very dark gray (Colors.grey[900])
          surfaceContainer: Color(
            0xFF303030,
          ), // Medium dark gray (Colors.grey[850])
          primary: Colors.blue, // Accent color
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          // foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(color: Color(0xFF1E1E1E), elevation: 2),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF212121), // Very dark gray (Colors.grey[900])
          surfaceContainer: Color(
            0xFF303030,
          ), // Medium dark gray (Colors.grey[850])
          primary: Colors.blue, // Accent color
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          // foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(color: Color(0xFF1E1E1E), elevation: 2),
      ),
      routerConfig: _router,
    );
  }
}
