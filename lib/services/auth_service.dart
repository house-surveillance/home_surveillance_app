import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class AuthService extends ChangeNotifier {
  //'http://192.168.18.5:3000/api/v1/auth';
  //'http://localhost:3000/api/v1/auth';
  final String baseUrl = 'http://192.168.18.5:3000/api/v1/auth';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setString('userId', responseData['id'].toString());
        //FireBase notifications initialization

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

/*Future<bool> registerUser(
      String email,
      String password,
      String userName,
      String fullName,
      List<String> userRoles,
      XFile imageProfile
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
        'userName': userName,
        "profile":{
          "fullName": fullName
        },
        "roles": userRoles,
        "file": imageProfile
      }),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
  */

  Future<Map<String, dynamic>> registerUser(
      String email,
    String password,
    String userName,
    String fullName,
    List<String> userRoles,
    XFile? imageProfile,
      residenceName,
      residenceAddress,
      creatorId
  ) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/register'));

      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['userName'] = userName;
      request.fields['fullName'] = fullName;
      request.fields['creatorId'] = creatorId;
      request.fields['roles'] = userRoles.join(',');

      if (imageProfile != null) {
        var mimeType = lookupMimeType(imageProfile.path)!.split('/');
        var file = await http.MultipartFile.fromPath(
          'file',
          imageProfile.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        );
        request.files.add(file);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        Map<String, dynamic> result = {
          'message': 'something went wrong',
          'ok': true,
          'response': json.decode(response.body),
        };
        return result;
      } else {
        Map<String, dynamic> result = {
          'message': 'Error: ${response.statusCode}, ${response.body}',
          'ok': false,
          'response': json.decode(response.body),
        };

        return result;
      }
    } catch (e) {
      Map<String, dynamic> result = {
        'message': 'something went wrong',
        'ok': false
      };
      return result;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('token');
  }
}
