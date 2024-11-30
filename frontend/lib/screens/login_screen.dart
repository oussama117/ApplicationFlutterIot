// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Save token and role in SharedPreferences
  Future<void> _saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('userRole', role);
  }

  // Validate the form fields
  bool _validateFields(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
      });
      return false;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return false;
    }

    return true;
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Perform the login process
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate fields before proceeding
    if (!_validateFields(email, password)) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.login(email, password);

      if (response['token'] != null) {
        // Save token and role on successful login
        await _saveToken(response['token'], response['role']);

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(role: response['role']),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Invalid credentials.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check if the user is already logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final role = prefs.getString('userRole');

    if (token != null && role != null) {
      // If already logged in, navigate to the appropriate home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(role: role),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if the user is already logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Login')),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 350,
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const Text(
                  //   'Sign in',
                  //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  // ),
                  Image.asset(
                    'assets/img/profile.png',
                    height: 150,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      floatingLabelStyle: const TextStyle(color: Colors.orange),
                      errorText:
                          _errorMessage == 'Please enter a valid email address.'
                              ? _errorMessage
                              : null,
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      floatingLabelStyle: const TextStyle(color: Colors.orange),
                      errorText: _errorMessage == 'All fields are required.'
                          ? _errorMessage
                          : null,
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Contact your admin for account data'),
                  const SizedBox(height: 35),
                  // Login button or loading indicator
                  _isLoading
                      ? const Center(
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              )),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  // Display error message if any
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
