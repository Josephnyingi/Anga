import 'package:flutter/material.dart';

/// Shows a brief auto-dismissing confirmation toast.
///
/// MainScreen keeps all 5 bottom-nav tabs mounted at once via IndexedStack,
/// each with its own nested Scaffold, all sharing one ScaffoldMessenger -
/// showSnackBar was unreliable there. showDialog is used elsewhere in this
/// app (e.g. the language picker) and renders reliably regardless of tab
/// nesting, so this reuses that same mechanism styled to read as a toast.
void showAppToast(BuildContext context, String message, {Color? backgroundColor}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      Future.delayed(const Duration(seconds: 3), () {
        if (navigator.canPop()) navigator.pop();
      });
      return AlertDialog(
        backgroundColor: backgroundColor ?? const Color(0xFF323232),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      );
    },
  );
}
