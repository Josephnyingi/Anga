import 'package:flutter/material.dart';

class WebTheme {
  static const Color webPrimary   = Color(0xFF2563EB);
  static const Color webSecondary = Color(0xFF0D9488);
  static const Color webWarning   = Color(0xFFF59E0B);
  static const Color webError     = Color(0xFFEF4444);
  static const Color webInfo      = Color(0xFF3B82F6);
  static const Color webSuccess   = Color(0xFF10B981);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF0D9488)],
  );
}
