import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../utils/permissions_util.dart';
import 'user_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final authService = Provider.of<AuthService>(context);
    final cameraService = Provider.of<CameraService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final hasPermission =
                    await PermissionsUtil().requestCameraPermission();
                if (hasPermission) {
                  await cameraService.initializeCamera();
                  // Lógica para usar la cámara
                } else {
                  // Manejar falta de permiso
                }
              },
              child: const Text('Access Camera'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserManagementScreen()),
                );
              },
              child: const Text('Manage Users'),
            ),
          ],
        ),
      ),
    );
  }
}
