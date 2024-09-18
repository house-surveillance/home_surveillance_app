import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const route = '/notifications';
  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool intruderNotificationActive = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _createNotificationChannel();
    fetchNotification();
  }

  void _createNotificationChannel() async {
    var androidNotificationChannel = const AndroidNotificationChannel(
      'your_channel_id',
      'your_channel_name',
      description: 'your channel description',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  void fetchNotification() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.fetchData('notifications');
      List<NotificationModel> users = (response as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();

      handleNotifications(users);
    } catch (error) {
      // Handle error appropriately here
      print('Error fetching users: $error');
    }
    // Simulated user data
  }

  void handleNotifications(List<NotificationModel> users) {
    for (var user in users) {
      Color color;
      String title;
      if (user.type == 'Not Verified') {
        title = 'User Not Verified';
        color = Colors.orange;
      } else if (user.type == 'Not Verified/Intruder') {
        title = 'Intruder Alert';
        color = Colors.red;
        if (intruderNotificationActive) {
          // Repeat intruder notification
          Future.delayed(const Duration(minutes: 1), () {
            if (intruderNotificationActive) {
              handleNotifications(users);
            }
          });
        }
      } else {
        title = 'User Verified';
        color = Colors.green;
      }

      //DateTime timestamp = DateTime(user.timestamp);
      String formattedDate =
          DateFormat('yyyy-MM-dd – kk:mm').format(user.timestamp);
      //DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      //String formattedDate = dateFormat.format(user.timestamp);

      // Add notification to the list
      notifications.add({
        'title': title,
        'message': '${user.message} ',
        'imageUrl': user.imageUrl,
        'imageId': user.imageId,
        'time': formattedDate,
        'color': color,
      });
    }

    // Update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
    print('message');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              setState(() {
                intruderNotificationActive = false;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            color: notification['color'],
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                  image: notification['imageUrl'] != null &&
                          notification['imageUrl'].isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(notification['imageUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: notification['imageUrl'] == null ||
                        notification['imageUrl'].isEmpty
                    ? const Icon(
                        Icons.image,
                        color: Colors.white,
                      )
                    : null,
              ),
              title: Text(
                notification['title'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                notification['message'],
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                notification['time'],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
