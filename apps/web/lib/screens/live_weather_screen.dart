import 'package:flutter/material.dart';

/// 🌤️ **Live Weather Screen for Web**
/// 
/// This screen displays real-time weather information.
class LiveWeatherScreen extends StatefulWidget {
  const LiveWeatherScreen({super.key});

  @override
  State<LiveWeatherScreen> createState() => _LiveWeatherScreenState();
}

class _LiveWeatherScreenState extends State<LiveWeatherScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock weather data
      setState(() {
        _weatherData = {
          'location': 'Machakos, Kenya',
          'temperature': 25.0,
          'humidity': 60,
          'windSpeed': 12.0,
          'description': 'Partly Cloudy',
          'feelsLike': 27.0,
          'pressure': 1013,
          'visibility': 10.0,
          'uvIndex': 6,
          'timestamp': DateTime.now(),
        };
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeatherData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weatherData == null
              ? const Center(
                  child: Text('Failed to load weather data'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Weather Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                _weatherData!['location'],
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                Icons.wb_sunny,
                                size: 80,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_weatherData!['temperature']}°C',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _weatherData!['description'],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Feels like ${_weatherData!['feelsLike']}°C',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Weather Details
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weather Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow('Humidity', '${_weatherData!['humidity']}%'),
                              _buildDetailRow('Wind Speed', '${_weatherData!['windSpeed']} km/h'),
                              _buildDetailRow('Pressure', '${_weatherData!['pressure']} hPa'),
                              _buildDetailRow('Visibility', '${_weatherData!['visibility']} km'),
                              _buildDetailRow('UV Index', '${_weatherData!['uvIndex']}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
