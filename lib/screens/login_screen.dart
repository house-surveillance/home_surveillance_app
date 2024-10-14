import 'package:flutter/material.dart';
import 'package:home_surveillance_app/services/firebase_api.dart';
import '../utils/validations_util.dart';
import '../widgets/validation_dialog.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'user_management_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final email = emailController.text;
    final password = passwordController.text;

    Map<String, dynamic> fields = {
      "Email": email,
      "Password": password,
    };
    Map<String, ValidationRule> rules = {
      "Email": (value) => value.isNotEmpty,
      "Password": (value) => value.isNotEmpty,
    };
    String? missingFields = validateFields(fields, rules);

    if (missingFields != null) {
      if (mounted) {
        ValidationDialog(
          title: 'Missing fields',
          content: 'Please, complete the following fields: $missingFields.',
          textButton: 'Ok',
        ).show(context);
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final success = await authService.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      await FirebaseApi().initNotifications(context);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserManagementScreen()),
        );
      }
    } else {
      if (mounted) {
        const ValidationDialog(
          title: 'Login Failed',
          content: 'Invalid email or password.',
          textButton: 'Ok',
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Image at the top
                Image.asset(
                  'assets/logo1.png',
                  height: 150.0,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Welcome to HSurv',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                // Email TextField
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                // Password TextField
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  obscureText: _obscureText,
                ),
                const SizedBox(height: 20.0),
                // Log In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),

                  //onPressed: _isLoading ? null : _login,

                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Log In'),
                ),
                const SizedBox(height: 10.0),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text('Sign Up',
                          style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
