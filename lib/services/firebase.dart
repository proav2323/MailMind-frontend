import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseApp? app = null;
FirebaseMessaging msg = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> initFirebaseApp() async {
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void intilaizeMsg() {}

void getToken() {
  msg.getToken().then((value) {
    if (value != null) {
      log(value);
    }
  });
  msg.getAPNSToken().then((value) {
    if (value != null) {
      log(value);
    }
  });
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

Future<void> listenMsg() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _localNotifications.initialize(settings: initSettings);

  // 5. Handle Foreground Messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a foreground message: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If notification payload exists, manually render local alert banner
    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel Name
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  // 6. Handle App-Opened-From-Notification interactions (Background click)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked while app was in background state!');
    // Route parsing logic can go here
  });

  // 7. Extract the device token for testing payloads
  getToken();
}
