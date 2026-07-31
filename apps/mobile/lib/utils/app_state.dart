class AppState {
  static String selectedLocation = "Machakos";
  // Set when the farmer searches a location beyond the original two towns
  // (any IGAD-country place, via /geocode/); null means fall back to the
  // machakos/vhembe whitelist server-side.
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
