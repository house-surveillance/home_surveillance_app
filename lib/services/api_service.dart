import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  //http://192.168.18.5:3000/api/v1
  //http://localhost:3000/api/v1
  final String baseUrl = 'https://065f-38-253-146-9.ngrok-free.app/api/v1';

  Future<dynamic> fetchData(String endpoint) async {
    print('Endpoint: $endpoint');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          // Otros headers si los necesitas
        },
      );

      // Verificar el código de estado
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          // Decodificar solo si la respuesta no está vacía
          return json.decode(response.body);
        } else {
          // Manejo para respuesta vacía
          return null;
        }
      } else {
        // Manejo de errores por código de estado
        print('Error: Received status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Manejo de excepciones
      print('Error durante la solicitud GET: $e');
      return false;
    }
  }


  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'
      },
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }

  Future<dynamic> registerFace(List<XFile> userPhotos, String userID) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/recognition/register-face'));

    request.headers.addAll({'ngrok-skip-browser-warning': 'true'});

    request.fields['userID'] = userID;
    for (var photo in userPhotos) {
      var mimeType = lookupMimeType(photo.path)!.split('/');
      var file = await http.MultipartFile.fromPath(
        'files',
        photo.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      );
      request.files.add(file);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
