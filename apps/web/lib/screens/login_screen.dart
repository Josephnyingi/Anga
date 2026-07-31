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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and Title
                      Icon(
                        Icons.wb_sunny,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ANGA Weather',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI-Powered Weather & Farming Assistant',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '+254 700 000 000',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                      const SizedBox(height: 24),

                      // Remember me + forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              ),
                              const Text('Remember Me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _showMessage('Forgot Password', 'Contact support to reset your password.', Colors.blue),
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
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isRegistering ? 'Register' : 'Login'),
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
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Toggle register/login
                      TextButton(
                        onPressed: () => setState(() => _isRegistering = !_isRegistering),
                        child: Text(_isRegistering ? 'Already have an account? Login' : 'Don\'t have an account? Register'),
                      ),
                      const SizedBox(height: 16),

                      // Theme Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.light_mode),
                          Switch(
                            value: Theme.of(context).brightness == Brightness.dark,
                            onChanged: widget.setTheme,
                          ),
                          const Icon(Icons.dark_mode),
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
