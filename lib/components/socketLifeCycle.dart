import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/services/firebase.dart';
import 'package:mailmind/services/socket.dart';
import 'package:go_router/go_router.dart';
import 'package:mailmind/pages/home.dart';
import 'package:mailmind/pages/year.dart';
import 'package:mailmind/pages/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SocketLifecycleManager extends StatefulWidget {
  SocketService? SOCKET;
  SocketLifecycleManager({super.key});

  @override
  State<SocketLifecycleManager> createState() => _SocketLifecycleManagerState();
}

class _SocketLifecycleManagerState extends State<SocketLifecycleManager> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    getSocket();
    listenMsg();
    if (msg != null) {
      msg!.getNotificationSettings().then(
        (val) => {
          if (val.authorizationStatus == AuthorizationStatus.notDetermined)
            {
              msg!
                  .requestPermission(
                    alert: true,
                    announcement: false,
                    badge: true,
                    carPlay: false,
                    criticalAlert: false,
                    provisional: false,
                    sound: true,
                  )
                  .then((value) => {}),
            }
          else if (val.authorizationStatus == AuthorizationStatus.denied)
            {log("denied")},
        },
      );
    }

    _lifecycleListener = AppLifecycleListener(
      onHide: () => _disconnectSocket(),
      onDetach: () => _disconnectSocket(),
      onInactive: () => _disconnectSocket(),
    );
  }

  void listenMsg() {
    FirebaseMessaging.onMessage.listen((payload) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(payload.notification!.title ?? "you have anew email"),
        ),
      );
    });
  }

  void _disconnectSocket() {
    if (widget.SOCKET != null) {
      if (widget.SOCKET!.socket.connected) {
        widget.SOCKET!.disconnectSocket();
        print("Socket cleanly disconnected via lifecycle state change.");
      }
    }
  }

  void getSocket() {
    final container = ProviderContainer();
    container.listen(SOCKET, (prev, next) {
      next.when(
        error: (err, trace) {},
        data: (value) async {
          setState(() {
            widget.SOCKET = value;
          });
        },
        loading: () {},
      );
    }, onError: (err, trace) {});
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _disconnectSocket(); // Clean up if widget is destroyed
    super.dispose();
  }

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

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => MyHomePage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: "/year", builder: (context, state) => yearSelect()),
  ],
);
