import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home_surveillance_app/main.dart';
import 'package:home_surveillance_app/screens/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');
    print('ppp : ${token}');
    if (token != null && userId != null) {
      navigatorKey.currentState
          ?.pushNamed(NotificationsScreen.route, arguments: message);
    } else {
      navigatorKey.currentState?.pushNamed('/login', arguments: message);
    }
  }

  Future iniPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: ${fCMToken}');
    iniPushNotifications();
  }
}
