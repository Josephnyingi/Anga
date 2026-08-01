import 'package:flutter/foundation.dart';

class AppState {
  // A ValueNotifier so screens kept alive by IndexedStack (Alerts, Settings)
  // can rebuild when another tab changes the location, instead of showing
  // a stale value until they happen to rebuild for an unrelated reason.
  static final ValueNotifier<String> selectedLocationNotifier =
      ValueNotifier<String>("Machakos");

  static String get selectedLocation => selectedLocationNotifier.value;
  static set selectedLocation(String value) => selectedLocationNotifier.value = value;
  // Set when the farmer searches a location beyond the original two towns
  // (any IGAD-country place, via /geocode/); null means fall back to the
  // machakos/gulu whitelist server-side.
  static double? selectedLat;
  static double? selectedLon;
  static String phoneNumber = "";
  static bool isCelsius = true;
  static bool isMillimeters = true;
  static bool enableNotifications = true;
  static bool enableExtremeAlerts = true;
  static bool isDarkMode = false;

  static DateTime startDate = DateTime.now();
  static DateTime endDate = DateTime.now().add(const Duration(days: 6));
}
