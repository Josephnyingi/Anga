import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_weather_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void _setTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anga Weather App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      //initialRoute: '/',

      initialRoute: '/dashboard',

      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => MainScreen(setTheme: _setTheme),
        '/alerts': (context) => const AlertsScreen(),
        '/settings': (context) => SettingsScreen(setTheme: _setTheme),
        '/live_weather': (context) => const LiveWeatherScreen(),
        '/ai_assistant': (context) => const AIAssistantScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final void Function(bool) setTheme;

  const MainScreen({super.key, required this.setTheme});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(key: _dashboardKey),
      const AlertsScreen(),
      SettingsScreen(setTheme: widget.setTheme),
    ];
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _fetchWeatherUpdate() {
    if (_selectedIndex == 0) {
      _dashboardKey.currentState?.fetchWeather();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Weather data refreshed!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ANGA Weather"),
        backgroundColor: Colors.blueAccent,
      ),
drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blueAccent),
        child: Text(
          'ANGA Menu',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
      ),
      ListTile(
        leading: const Icon(Icons.cloud),
        title: const Text('Live Weather'),
        onTap: () => Navigator.pushNamed(context, '/live_weather'),
      ),
      ListTile(
        leading: const Icon(Icons.warning),
        title: const Text('Alerts'),
        onTap: () => Navigator.pushReplacementNamed(context, '/alerts'),
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
      ),
      // ✅ Add AI Assistant just before Logout
      ListTile(
        leading: const Icon(Icons.assistant),
        title: const Text('AI Assistant'),
        onTap: () {
          Navigator.pop(context); // Close the drawer first!
          Navigator.pushNamed(context, '/ai_assistant');
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: _logout,
      ),
    ],
  ),
),

      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _fetchWeatherUpdate,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.refresh, size: 28),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _logout,
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.logout, size: 28),
          ),
        ],
      ),
    );
  }
}
