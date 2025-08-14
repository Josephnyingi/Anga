import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ FastAPI Phone/Password Login
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final Uri url = Uri.parse("$API_BASE_URL/login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("phone_number", phone);
        return {"success": true, "message": "Login successful"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['detail']
        };
      }
    } catch (error) {
      return {"success": false, "message": "Server error: $error"};
    }
  }

  /// ✅ FastAPI Registration
  Future<Map<String, dynamic>> register(String name, String phone, String password) async {
    final Uri url = Uri.parse("$API_BASE_URL/users/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone_number": phone, "password": password}),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully!"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['detail']
        };
      }
    } catch (error) {
      return {"success": false, "message": "Server error: $error"};
    }
  }

  /// ✅ Firebase Google Sign-In (Currently Disabled)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    return {
      "success": false, 
      "message": "Google Sign-In is currently disabled. Please use phone/password login."
    };
  }

  /// ✅ Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
