import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_config.dart';

class LiveWeatherScreen extends StatefulWidget {
  const LiveWeatherScreen({super.key});

  @override
  State<LiveWeatherScreen> createState() => _LiveWeatherScreenState();
}

class _LiveWeatherScreenState extends State<LiveWeatherScreen> {
  bool isLoading = true;
  String? error;
  String? location;
  String? date;
  double? temperature; // store as number
  double? rain;        // store as number

  @override
  void initState() {
    super.initState();
    _fetchLiveWeather();
  }

  /// Handle back navigation
  void _handleBackNavigation() {
    // Check if we can pop the current route
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // If we can't pop, navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> _fetchLiveWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLocation = prefs.getString('location')?.toLowerCase() ?? 'machakos';

    if (!['machakos', 'vhembe'].contains(selectedLocation)) {
      setState(() {
        isLoading = false;
        error = "Live weather not available for '$selectedLocation'.";
      });
      return;
    }

    try {
      ApiConfig.debugPrint("Fetching live weather for $selectedLocation");
      
      final response = await http.get(
        Uri.parse('${ApiConfig.liveWeatherUrl}?location=$selectedLocation'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ApiConfig.debugPrint("Live weather data received successfully");

        setState(() {
          isLoading = false;
          location = data['location'];
          date = data['date'];
          temperature = (data['temperature_max'] as num).toDouble();
          rain = (data['rain_sum'] as num).toDouble();
        });
      } else {
        ApiConfig.debugPrint("Live weather API error: ${response.statusCode}");
        setState(() {
          isLoading = false;
          error = 'Failed to fetch live weather (${response.statusCode}).';
        });
      }
    } catch (e) {
      ApiConfig.debugPrint("Live weather network error: $e");
      setState(() {
        isLoading = false;
        error = 'Error fetching data. Check connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Weather", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        // Add back button for proper navigation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackNavigation,
        ),
        // Add actions for additional functionality
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                error = null;
              });
              _fetchLiveWeather();
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              _showLocationDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading live weather data...'),
                ],
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading weather data',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchLiveWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Main weather card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.teal,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Live Weather in ${location ?? '--'}",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Date: ${date ?? '--'}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildWeatherInfo(
                                      icon: Icons.thermostat,
                                      label: "Temperature",
                                      value: "${temperature?.toStringAsFixed(1) ?? '--'} °C",
                                      color: Colors.red[400]!,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildWeatherInfo(
                                      icon: Icons.water_drop,
                                      label: "Rainfall",
                                      value: "${rain?.toStringAsFixed(1) ?? '--'} mm",
                                      color: Colors.blue[400]!,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Additional info card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Weather Summary",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryItem(
                                "Data Source",
                                "Real-time weather API",
                                Icons.cloud,
                                isDarkMode,
                              ),
                              _buildSummaryItem(
                                "Last Updated",
                                "Just now",
                                Icons.access_time,
                                isDarkMode,
                              ),
                              _buildSummaryItem(
                                "Accuracy",
                                "High precision",
                                Icons.verified,
                                isDarkMode,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWeatherInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.teal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: const Text(
          'Live weather is currently available for Machakos and Vhembe. You can change your preferred location in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }
}
