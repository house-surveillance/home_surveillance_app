import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/camera_service.dart';
import 'package:provider/provider.dart';
import 'screens/notifications_screen.dart';
import 'services/firebase_api.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => CameraService()),
      ],
      child: MaterialApp(
        title: 'HSurv',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: navigatorKey,
        home: const WelcomeScreen(),
        routes: {
          LoginScreen.route: (context) => const LoginScreen(),
          NotificationsScreen.route: (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}
