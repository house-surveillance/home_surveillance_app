import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:home_surveillance_app/main.dart';
import 'package:home_surveillance_app/screens/notifications_screen.dart';
import 'package:home_surveillance_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //print('Title: ${message.notification?.title}');
  //print('Body: ${message.notification?.body}');
  //print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');
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

  Future<void> initNotifications(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {

      try {
        final response = await apiService.fetchData('users/fCMToken/$userId');
        //print(response);
        if (!response) {
          final fCMToken = await _firebaseMessaging.getToken();
          print('fCMToken');
          print(fCMToken);
            await apiService.postData(
              'users/fCMToken',
              {'userId': userId, 'fcmToken': fCMToken},
            );

        } else {
          //print('Token FCM existente: $response');
        }
      } catch (e) {
        //print('Error al obtener o enviar el token FCM: $e');
      }
    }
    await _firebaseMessaging.requestPermission();
    iniPushNotifications();
  }
}
