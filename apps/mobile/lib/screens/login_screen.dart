// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../utils/app_state.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool)? setTheme;
  
  const LoginScreen({super.key, this.setTheme});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  // Matches the web app's pre-filled demo login (0700000000 / demo1234) -
  // mobile's fields were empty, requiring judges/reviewers to know and
  // type the demo credentials themselves instead of just tapping Login.
  final TextEditingController _phoneController = TextEditingController(text: '0700000000');
  final TextEditingController _passwordController = TextEditingController(text: 'demo1234');

  bool _isLoading = false;
  bool _isRegistering = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    final result = await _authService.login(phone, password);

    setState(() => _isLoading = false);

    if (result['success']) {
      AppState.phoneNumber = phone;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _showMessage("Error", result['message'], Colors.red);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    final result = await _authService.register("User", phone, password);

    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage("Success", result['message'], Colors.green);
      _toggleMode();
    } else {
      _showMessage("Error", result['message'], Colors.red);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final result = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _showMessage("Google Sign-In Failed", result['message'], Colors.red);
    }
  }

  void _showMessage(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => BounceInDown(
        duration: const Duration(milliseconds: 500),
        child: AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  void _toggleMode() {
    setState(() => _isRegistering = !_isRegistering);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                // Was Image.asset('assets/images/farming.jpg') - an
                // unlicensed iStock preview image with the watermark still
                // visible. Replaced with the same icon-based header the web
                // app uses rather than a photo of uncertain provenance.
                child: const Text('🌤️', style: TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 15),

              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: const Column(
                  children: [
                    Text(
                      // Was "Anga - AI-Powered Climate Forecasts" - a
                      // different name than the "ANGA Weather" title shown
                      // on every other screen (dashboard app bar, web app).
                      "ANGA Weather",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "AI-Powered Weather & Farming Assistant",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.trim().isEmpty ? 'Enter your phone number' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => value!.trim().isEmpty ? 'Enter your password' : null,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Demo account pre-filled — just tap Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) => setState(() => _rememberMe = value!),
                            ),
                            const Text("Remember Me"),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _showMessage(
                            "Forgot Password",
                            "Contact support to reset your password:\njosenyingi@gmail.com\n+254 708 171 889",
                            Colors.blue,
                          ),
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _isRegistering ? _handleRegister : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            ),
                            child: Text(_isRegistering ? "Register" : "Login"),
                          ),
                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text("Sign in with Google"),
                      onPressed: _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(_isRegistering ? "Already have an account? Login" : "Don't have an account? Register"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}