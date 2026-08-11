import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mailmind/services/api.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log(message.toString());
}

class FirebaseSetup {
  static final FirebaseMessaging msg = FirebaseMessaging.instance;
  FirebaseApp? app = Firebase.apps.isNotEmpty ? Firebase.apps[0] : null;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await msg.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await listenMsg();
  }

  Future<String?> getToken() async {
    try {
      await msg.getAPNSToken();
      String? token = await msg.getToken();
      return token;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getFirebaseInstallationId() async {
    log(app.toString());
    try {
      if (app != null) {
        // String fid = await FirebaseInstallations.instanceFor(app: app!).getId();
        String fid = await FirebaseInstallations.instance.getId();
        return fid;
      } else {
        return null;
      }
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
    msg.onTokenRefresh.listen((newToken) async {
      log(newToken);
      await saveFid();
    });
    // 7. Extract the device token for testing payloads
    getToken();
  }
}
