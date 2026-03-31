import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// 🌐 **Web-Specific Utilities**
/// 
/// Utility functions and helpers optimized for web platforms
class WebUtils {
  // Platform detection
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !isWeb;
  
  // Screen size helpers
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  // Responsive value helper
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeScreen(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    } else if (isMediumScreen(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
  
  // Safe area helpers
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
  
  // Keyboard helpers
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
  
  // Scroll helpers
  static void scrollToTop(ScrollController controller) {
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  
  static void scrollToBottom(ScrollController controller) {
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  
  // Focus helpers
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }
  
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
  
  // Navigation helpers
  static void navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  
  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }
  
  // Dialog helpers
  static Future<T?> showWebDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      builder: (context) => child,
    );
  }
  
  static Future<T?> showWebBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }
  
  // Snackbar helpers
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Validation helpers
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
  
  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }
  
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  // Number helpers
  static String formatNumber(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals);
  }
  
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${formatNumber(amount)}';
  }
  
  static String formatPercentage(double value) {
    return '${formatNumber(value * 100)}%';
  }
  
  // Date helpers
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    // Simple date formatting - in production, use intl package
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    switch (format) {
      case 'MMM dd, yyyy':
        return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      default:
        return date.toString();
    }
  }
  
  static String formatTime(DateTime time, {bool use24Hour = false}) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }
  
  // Color helpers
  static Color hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
  
  static Color lightenColor(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }
  
  static Color darkenColor(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }
  
  // Animation helpers
  static Duration getFastDuration() => const Duration(milliseconds: 200);
  static Duration getNormalDuration() => const Duration(milliseconds: 300);
  static Duration getSlowDuration() => const Duration(milliseconds: 500);
  
  static Curve getEaseInCurve() => Curves.easeIn;
  static Curve getEaseOutCurve() => Curves.easeOut;
  static Curve getEaseInOutCurve() => Curves.easeInOut;
  
  // Performance helpers
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    // Simple debounce implementation
    Future.delayed(delay, callback);
  }
  
  static void throttle(VoidCallback callback, {Duration delay = const Duration(milliseconds: 100)}) {
    // Simple throttle implementation
    Future.delayed(delay, callback);
  }
  
  // Storage helpers (for web)
  static void setLocalStorage(String key, String value) {
    // In a real implementation, use shared_preferences or localStorage
    if (kIsWeb) {
      // Web storage implementation
      print('Setting $key: $value');
    }
  }
  
  static String? getLocalStorage(String key) {
    // In a real implementation, use shared_preferences or localStorage
    if (kIsWeb) {
      // Web storage implementation
      return null;
    }
    return null;
  }
  
  static void removeLocalStorage(String key) {
    // In a real implementation, use shared_preferences or localStorage
    if (kIsWeb) {
      // Web storage implementation
      print('Removing $key');
    }
  }
  
  // URL helpers
  static void launchUrl(String url) {
    // In a real implementation, use url_launcher
    if (kIsWeb) {
      // Web URL launching
      print('Launching URL: $url');
    }
  }
  
  // Copy to clipboard
  static void copyToClipboard(String text) {
    // In a real implementation, use flutter/services
    if (kIsWeb) {
      // Web clipboard implementation
      print('Copying to clipboard: $text');
    }
  }
}
