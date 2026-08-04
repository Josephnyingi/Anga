import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_state.dart';

/// 🔐 **Login Screen for Web**
///
/// This screen handles user authentication for the web application.
class LoginScreen extends StatefulWidget {
  final void Function(bool)? setTheme;

  const LoginScreen({super.key, this.setTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Pre-filled with a working demo account so judges/reviewers can log in
  // immediately without registering first.
  final _phoneController = TextEditingController(text: '0700000000');
  final _passwordController = TextEditingController(text: 'demo1234');
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _glassDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
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
      focusedErrorBorder: OutlineInputBorder(
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
    final primary = Theme.of(context).primaryColor;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Stack(
        children: [
          // Liquid gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
            ),
          ),
          // Soft blurred color blobs for depth ("liquid" feel)
          _blob(size: 320, color: secondary, top: -100, left: -80),
          _blob(size: 380, color: Colors.white, bottom: -140, right: -100),
          _blob(size: 240, color: primary, bottom: 60, left: -60),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: ClipRRect(
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
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo and Title
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Icon(Icons.wb_sunny, size: 48, color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'ANGA Weather',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Weather forecasts and early-warning alerts for smallholder farmers — heat, frost, flood, drought & livestock heat stress.',
                                style: TextStyle(color: Colors.white.withOpacity(0.85)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Phone Number Field
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: _glassDecoration(
                                  label: 'Phone Number',
                                  icon: Icons.phone,
                                  hint: '+254 700 000 000',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  final digitCount = value.replaceAll(RegExp(r'[^0-9]'), '').length;
                                  if (digitCount < 7) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: _glassDecoration(
                                  label: 'Password',
                                  icon: Icons.lock,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Demo account pre-filled — just tap Login',
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65)),
                              ),
                              const SizedBox(height: 16),

                              // Remember me + forgot password - Wrap instead of Row
                              // so "Forgot Password?" drops to its own line on
                              // narrow screens instead of overflowing (this row had
                              // no Expanded/Flexible, so it silently clipped by 37px
                              // at mobile widths - invisible in release builds,
                              // where Flutter's overflow warning doesn't render).
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                        fillColor: WidgetStateProperty.resolveWith((states) =>
                                            states.contains(WidgetState.selected)
                                                ? Colors.white
                                                : Colors.transparent),
                                        checkColor: primary,
                                        side: BorderSide(color: Colors.white.withOpacity(0.7)),
                                      ),
                                      Text('Remember Me', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => _showMessage(
                                      'Forgot Password',
                                      'Contact support to reset your password:\njosenyingi@gmail.com\n+254 708 171 889',
                                      Colors.blue,
                                    ),
                                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                                    child: const Text('Forgot Password?'),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Login/Register Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : (_isRegistering ? _handleRegister : _handleLogin),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                                        )
                                      : Text(
                                          _isRegistering ? 'Register' : 'Login',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Google Sign-in
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  icon: const Icon(Icons.login, color: Colors.white),
                                  label: const Text('Sign in with Google'),
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
                              const SizedBox(height: 12),

                              // Toggle register/login
                              TextButton(
                                onPressed: () => setState(() => _isRegistering = !_isRegistering),
                                style: TextButton.styleFrom(foregroundColor: Colors.white.withOpacity(0.85)),
                                child: Text(_isRegistering ? 'Already have an account? Login' : 'Don\'t have an account? Register'),
                              ),
                              const SizedBox(height: 16),

                              // Theme Toggle
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.light_mode, color: Colors.white.withOpacity(0.85)),
                                  Semantics(
                                    label: 'Dark mode',
                                    child: Switch(
                                      value: Theme.of(context).brightness == Brightness.dark,
                                      onChanged: widget.setTheme,
                                      activeColor: Colors.white,
                                      activeTrackColor: Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                  Icon(Icons.dark_mode, color: Colors.white.withOpacity(0.85)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final result = await AuthService.login(phone, password);

      if (mounted) {
        if (result['success'] == true) {
          AppState.phoneNumber = phone;
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showMessage('Login Failed', result['message']?.toString() ?? 'Unknown error', Theme.of(context).colorScheme.error);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final result = await AuthService.register(phone, password);
      if (mounted) {
        if (result['success'] == true) {
          _showMessage('Success', result['message']?.toString() ?? 'Registered', Colors.green);
          setState(() => _isRegistering = false);
        } else {
          _showMessage('Registration Failed', result['message']?.toString() ?? 'Unknown error', Colors.red);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final res = await AuthService.signInWithGoogle();
      if (mounted) {
        if (res['success'] == true) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showMessage('Google Sign-In', res['message']?.toString() ?? 'Unavailable', Colors.orange);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: color)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}
