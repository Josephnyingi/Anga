// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../utils/app_state.dart';
import '../theme.dart';

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

  InputDecoration _glassDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
      prefixIcon: Icon(
        label == 'Phone Number' ? Icons.phone : Icons.lock,
        color: Colors.white.withOpacity(0.85),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade200, width: 1.5),
      ),
      errorStyle: TextStyle(color: Colors.red.shade100),
    );
  }

  Widget _blob({required double size, required Color color, double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.55), color.withOpacity(0.0)],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.primaryColor;
    const secondary = AppTheme.secondaryColor;

    return Scaffold(
      body: Stack(
        children: [
          // Liquid gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
            ),
          ),
          // Soft blurred color blobs for depth ("liquid" feel)
          _blob(size: 280, color: secondary, top: -90, left: -70),
          _blob(size: 340, color: Colors.white, bottom: -120, right: -90),
          _blob(size: 200, color: primary, bottom: 40, left: -50),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(28.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeInDown(
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: const Text('🌤️', style: TextStyle(fontSize: 48)),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                FadeInUp(
                                  duration: const Duration(milliseconds: 500),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "ANGA Weather",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Weather forecasts and early-warning alerts for smallholder farmers — heat, frost, flood, drought & livestock heat stress.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 25),

                                TextFormField(
                                  controller: _phoneController,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  decoration: _glassDecoration(label: 'Phone Number'),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value!.trim().isEmpty ? 'Enter your phone number' : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  decoration: _glassDecoration(
                                    label: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (value) => value!.trim().isEmpty ? 'Enter your password' : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Demo account pre-filled — just tap Login',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65)),
                                ),
                                const SizedBox(height: 10),

                                // Wrap instead of Row so "Forgot Password?" drops to
                                // its own line on narrow screens instead of
                                // overflowing - same fix as the web app.
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) => setState(() => _rememberMe = value!),
                                          fillColor: WidgetStateProperty.resolveWith((states) =>
                                              states.contains(WidgetState.selected)
                                                  ? Colors.white
                                                  : Colors.transparent),
                                          checkColor: primary,
                                          side: BorderSide(color: Colors.white.withOpacity(0.7)),
                                        ),
                                        Text("Remember Me", style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () => _showMessage(
                                        "Forgot Password",
                                        "Contact support to reset your password:\njosenyingi@gmail.com\n+254 708 171 889",
                                        Colors.blue,
                                      ),
                                      child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isRegistering ? _handleRegister : _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: primary,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            _isRegistering ? "Register" : "Login",
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.login, color: Colors.white),
                                    label: const Text("Sign in with Google"),
                                    onPressed: _handleGoogleSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: BorderSide(color: Colors.white.withOpacity(0.35)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                TextButton(
                                  onPressed: _toggleMode,
                                  style: TextButton.styleFrom(foregroundColor: Colors.white.withOpacity(0.85)),
                                  child: Text(_isRegistering ? "Already have an account? Login" : "Don't have an account? Register"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
