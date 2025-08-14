import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_weather_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/debug_screen.dart';
import 'providers/weather_provider.dart';
import 'services/connectivity_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/performance_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/port_config_test.dart';
import 'utils/weather_service_test.dart';
import 'utils/environment_config.dart';
import 'utils/api_config.dart';
import 'theme.dart'; // Import the enhanced theme

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
    PerformanceService().initialize();
    
    // 🧪 Run port configuration test on startup
    PortConfigTest.runTest();
    
    // 🌤️ Run weather service test on startup
    await WeatherServiceTest.runComprehensiveTest();
    
    ApiConfig.debugPrint("🚀 All services initialized successfully");
  } catch (e) {
    debugPrint('❌ Error during app initialization: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        debugShowCheckedModeBanner: false, // Disabled for clean demo experience - set to true for development debugging
        title: 'Anga Weather App',
        theme: AppTheme.lightTheme, // Use enhanced light theme
        darkTheme: AppTheme.darkTheme, // Use enhanced dark theme
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(setTheme: _setTheme),
          '/dashboard': (context) => MainScreen(setTheme: _setTheme),
          '/alerts': (context) => const AlertsScreen(),
          '/settings': (context) => SettingsScreen(setTheme: _setTheme),
          '/live_weather': (context) => const LiveWeatherScreen(),
          '/ai_assistant': (context) => const AIAssistantScreen(),
          '/debug': (context) => const DebugScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent text scaling issues
            ),
            child: child!,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up services
    PerformanceService().dispose();
    ConnectivityService().dispose();
    super.dispose();
  }
}
