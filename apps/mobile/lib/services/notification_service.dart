import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/api_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Initialize the service
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      ApiConfig.debugPrint("✅ Notification service initialized");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to initialize notification service: $e");
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    ApiConfig.debugPrint("📱 Notification tapped: ${response.payload}");
    // Handle notification tap - navigate to specific screen
  }

  // Show weather alert notification
  Future<void> showWeatherAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'weather_alerts',
        'Weather Alerts',
        channelDescription: 'Important weather alerts and warnings',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );

      ApiConfig.debugPrint("📱 Weather alert notification sent: $title");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to show weather alert: $e");
    }
  }

  // Show daily forecast notification
  Future<void> showDailyForecast({
    required String location,
    required String temperature,
    required String rainfall,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_forecast',
        'Daily Forecast',
        channelDescription: 'Daily weather forecast updates',
        importance: Importance.low,
        priority: Priority.low,
        showWhen: true,
        enableVibration: false,
        playSound: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1, // Fixed ID for daily forecast
        'Daily Weather Forecast',
        '$location: $temperature°C, $rainfall mm rain',
        details,
        payload: 'daily_forecast',
      );

      ApiConfig.debugPrint("📱 Daily forecast notification sent for $location");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to show daily forecast: $e");
    }
  }

  // Show extreme weather warning
  Future<void> showExtremeWeatherWarning({
    required String location,
    required String condition,
    required String severity,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'extreme_weather',
        'Extreme Weather',
        channelDescription: 'Extreme weather warnings and alerts',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('warning_sound'),
        color: Color(0xFFFF4444),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '⚠️ Extreme Weather Warning',
        '$location: $condition - $severity',
        details,
        payload: 'extreme_weather',
      );

      ApiConfig.debugPrint("⚠️ Extreme weather warning sent for $location");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to show extreme weather warning: $e");
    }
  }

  // Schedule daily forecast notification
  Future<void> scheduleDailyForecast({
    required String location,
    required String temperature,
    required String rainfall,
    int hour = 8,
    int minute = 0, // 8:00 AM default
  }) async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_forecast',
        'Daily Forecast',
        channelDescription: 'Daily weather forecast updates',
        importance: Importance.low,
        priority: Priority.low,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        1,
        'Daily Weather Forecast',
        '$location: $temperature°C, $rainfall mm rain',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'daily_forecast',
      );

      ApiConfig.debugPrint("📅 Daily forecast scheduled for ${scheduledDate.toString()}");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to schedule daily forecast: $e");
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      ApiConfig.debugPrint("🗑️ All notifications cancelled");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to cancel notifications: $e");
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      ApiConfig.debugPrint("🗑️ Notification $id cancelled");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to cancel notification $id: $e");
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to get pending notifications: $e");
      return [];
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidEnabled = await _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled();
      return androidEnabled ?? false;
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to check notification status: $e");
      return false;
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final androidGranted = await _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      
      final iosGranted = await _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return (androidGranted ?? false) || (iosGranted ?? false);
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to request notification permissions: $e");
      return false;
    }
  }
} 