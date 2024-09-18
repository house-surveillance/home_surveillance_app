import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    await controller!.initialize();
  }
}
