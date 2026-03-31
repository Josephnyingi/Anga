// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// 🔔 Notification Service for Web
///
/// Uses the browser Notifications API to show real push notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _permissionGranted = false;

  Future<void> initialize() async {
    await requestPermissions();
  }

  Future<bool> requestPermissions() async {
    try {
      if (html.Notification.supported) {
        final permission = await html.Notification.requestPermission();
        _permissionGranted = permission == 'granted';
      }
    } catch (_) {}
    return _permissionGranted;
  }

  Future<bool> areNotificationsEnabled() async => _permissionGranted;

  Future<void> showWeatherAlert({
    required String title,
    required String body,
    String? payload,
  }) async => _show(title, body);

  Future<void> showDailyForecast({
    required String location,
    required String temperature,
    required String rainfall,
  }) async => _show('Daily Forecast — $location', '$temperature  ·  $rainfall rain');

  Future<void> showExtremeWeatherWarning({
    required String location,
    required String condition,
    required String severity,
  }) async => _show('⚠️ Extreme Weather — $location', '$condition ($severity)');

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async => _show(title, body);

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;
    Future.delayed(delay, () => _show(title, body));
  }

  Future<void> cancelNotification(int id) async {}
  Future<void> cancelAllNotifications() async {}

  void _show(String title, String body) {
    if (!_permissionGranted || !html.Notification.supported) return;
    try {
      html.Notification(title, body: body);
    } catch (_) {}
  }
}
