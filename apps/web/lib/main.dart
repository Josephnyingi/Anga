import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_weather_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'providers/weather_provider.dart';
import 'services/connectivity_service.dart';
import 'services/storage_service.dart';
import 'utils/environment_config.dart';
import 'utils/api_config.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize environment configuration
    EnvironmentConfig.validateConfiguration();
    
    // Initialize services
    await StorageService().initialize();
    await ConnectivityService().initialize();
    
    print("🚀 ANGA Weather Web App starting...");
    print("🌐 Platform: Web Browser");
    print("🔗 Backend URL: ${ApiConfig.baseUrl}");
    print("📱 Environment: ${EnvironmentConfig.environmentName}");
    
  } catch (e) {
    print("❌ Initialization error: $e");
  }
  
  runApp(const AngaWeatherApp());
}

class AngaWeatherApp extends StatelessWidget {
  const AngaWeatherApp({super.key});

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
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
        routes: {
          '/dashboard': (context) => const MainScreen(),
          '/alerts': (context) => const AlertsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/live-weather': (context) => const LiveWeatherScreen(),
          '/ai-assistant': (context) => const AIAssistantScreen(),
        },
      ),
    );
  }
}