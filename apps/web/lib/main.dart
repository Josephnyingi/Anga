import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_weather_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'providers/weather_provider.dart';
import 'services/connectivity_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'utils/environment_config.dart';
import 'utils/api_config.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize environment configuration
    EnvironmentConfig.validateConfiguration();

    // Initialize Firebase
    if (EnvironmentConfig.enableFirebase) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Initialize services
    await StorageService().initialize();
    await ConnectivityService().initialize();
    await NotificationService().initialize();

    debugPrint("🚀 ANGA Weather Web App starting...");
    debugPrint("🌐 Platform: Web Browser");
    debugPrint("🔗 Backend URL: ${ApiConfig.baseUrl}");
    debugPrint("📱 Environment: ${EnvironmentConfig.environmentName}");

  } catch (e) {
    debugPrint("❌ Initialization error: $e");
  }

  runApp(const AngaWeatherApp());
}

class AngaWeatherApp extends StatefulWidget {
  const AngaWeatherApp({super.key});

  @override
  State<AngaWeatherApp> createState() => _AngaWeatherAppState();
}

class _AngaWeatherAppState extends State<AngaWeatherApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final storage = StorageService();
    final savedTheme = storage.getTheme();
    setState(() {
      isDarkMode = savedTheme;
    });
  }

  void _setTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    StorageService().saveTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        title: 'ANGA Weather',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(setTheme: _setTheme),
          '/dashboard': (context) => MainScreen(setTheme: _setTheme),
          '/alerts': (context) => const AlertsScreen(),
          '/settings': (context) => SettingsScreen(setTheme: _setTheme),
          '/live-weather': (context) => const LiveWeatherScreen(),
          '/ai-assistant': (context) => const AIAssistantScreen(),
        },
      ),
    );
  }

  @override
  void dispose() {
    ConnectivityService().dispose();
    super.dispose();
  }
}