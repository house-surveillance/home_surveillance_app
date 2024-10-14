import 'dart:io';
import '../utils/validations_util.dart';
import '../widgets/validation_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;
  XFile? _selectedImage;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController residenceNameController = TextEditingController();
  final TextEditingController residenceAddressController = TextEditingController();

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _registerUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final email = emailController.text;
    final password = passwordController.text;
    final userName = userNameController.text;
    final fullName = fullNameController.text;
    final residenceName = residenceNameController.text;
    final residenceAddress = residenceAddressController;
    List<String> userRoles = ["ADMIN"];

    Map<String, dynamic> fields = {
      "Email": email,
      "Password": password,
      "UserName": userName,
      "FullName": fullName,
      "Image Profile": _selectedImage,
      "Residence Name": residenceName,
      "Residence Address": residenceAddress
    };

    Map<String, ValidationRule> rules = {
      "Email": (value) => value.isNotEmpty,
      "Password": (value) => value.isNotEmpty,
      "UserName": (value) => value.isNotEmpty,
      "FullName": (value) => value.isNotEmpty,
      "Image Profile": (value) => value != null,
      "Residence Name":  (value) => value.isNotEmpty,
      "Residence Address":  (value) => value.isNotEmpty
    };

    String? missingFields = validateFields(fields, rules);

    if (missingFields != null) {
      ValidationDialog(
        title: 'Missing fields',
        content: 'Please, complete the following fields: $missingFields.',
        textButton: 'Ok',
      ).show(context);
      return;
    }

    final result = await authService.registerUser(
        email, password, userName, fullName, userRoles, _selectedImage, residenceName, residenceAddress,'0');

    if (!mounted) return;
    if (result['ok']) {
      ValidationDialog(
        title: 'Successful registration',
        content: 'user registered successfully',
        textButton: 'Ok',
        onButtonPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
      ).show(context);
    } else {
      ValidationDialog(
        title: 'Something went wrong',
        content: 'User failed to register, try again',
        textButton: 'Ok',
        onButtonPressed: () {
          Navigator.of(context).pop();
        },
      ).show(context);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Welcome to HSurv',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/logo1.png',
                      fit: BoxFit.cover,
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.person_pin_rounded),
                      label: const Text('Upload profile image'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _selectedImage != null
                        ? SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 150,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No image selected',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: userNameController,
                        decoration: const InputDecoration(
                          labelText: 'userName',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'fullName',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        obscureText: _obscureText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    /*Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: residenceNameController,
                        decoration: const InputDecoration(
                          labelText: 'residence name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: residenceAddressController,
                        decoration: const InputDecoration(
                          labelText: 'residence address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),*/
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
