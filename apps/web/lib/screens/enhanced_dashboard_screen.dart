import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web_card.dart';
import '../widgets/web_animations.dart';
import '../widgets/web_loading_states.dart';
import '../widgets/web_indicators.dart';
import '../widgets/web_forms.dart';
import '../theme/web_theme.dart';

/// 📊 **Enhanced Dashboard Screen for Web**
/// 
/// Modern dashboard with web-specific optimizations and responsive design
class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _selectedLocation = 'Machakos';
  final List<String> _locations = ['Machakos', 'Vhembe', 'Nairobi', 'Kisumu'];

  // Mock data
  final Map<String, dynamic> _weatherData = {
    'temperature': 25.0,
    'humidity': 60,
    'windSpeed': 12.0,
    'pressure': 1013,
    'uvIndex': 6,
    'description': 'Partly Cloudy',
    'feelsLike': 27.0,
    'visibility': 10.0,
  };

  final List<Map<String, dynamic>> _forecast = [
    {'day': 'Today', 'high': 28, 'low': 18, 'condition': 'sunny', 'precip': 0},
    {'day': 'Tomorrow', 'high': 26, 'low': 16, 'condition': 'cloudy', 'precip': 20},
    {'day': 'Wed', 'high': 24, 'low': 14, 'condition': 'rainy', 'precip': 80},
    {'day': 'Thu', 'high': 27, 'low': 17, 'condition': 'sunny', 'precip': 10},
    {'day': 'Fri', 'high': 29, 'low': 19, 'condition': 'sunny', 'precip': 0},
  ];

  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'High Temperature Warning',
      'message': 'Temperatures expected to reach 35°C today',
      'type': 'warning',
      'time': '2 hours ago',
    },
    {
      'title': 'Rain Forecast',
      'message': 'Light rain expected tomorrow morning',
      'type': 'info',
      'time': '5 hours ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Simulate refresh
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? WebLoadingStates.fullScreenLoading(message: 'Loading weather data...')
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    
                    // Quick Stats
                    _buildQuickStatsSection(),
                    
                    // Main Content Grid
                    _buildMainContentGrid(),
                    
                    // Alerts Section
                    _buildAlertsSection(),
                    
                    // Forecast Section
                    _buildForecastSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: _isRefreshing
          ? const WebLoadingIndicator(size: 20)
          : FloatingActionButton(
              onPressed: _refreshData,
              tooltip: 'Refresh Data',
              child: const Icon(Icons.refresh),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: WebTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Selector
          Row(
            children: [
              Expanded(
                child: WebSearchField(
                  hint: 'Search location...',
                  onChanged: (value) {
                    // Handle search
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedLocation,
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value!;
                  });
                },
                items: _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Welcome Message
          WebAnimations.fadeIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s your weather overview for $_selectedLocation',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: ResponsiveGrid(
        children: [
          MetricCard(
            label: 'Temperature',
            value: '${_weatherData['temperature']}',
            unit: '°C',
            icon: Icons.thermostat,
            valueColor: WebTheme.webPrimary,
            trend: '+2°C',
            trendColor: Colors.green,
          ),
          MetricCard(
            label: 'Humidity',
            value: '${_weatherData['humidity']}',
            unit: '%',
            icon: Icons.water_drop,
            valueColor: WebTheme.webInfo,
          ),
          MetricCard(
            label: 'Wind Speed',
            value: '${_weatherData['windSpeed']}',
            unit: 'km/h',
            icon: Icons.air,
            valueColor: WebTheme.webSecondary,
          ),
          MetricCard(
            label: 'UV Index',
            value: '${_weatherData['uvIndex']}',
            icon: Icons.wb_sunny,
            valueColor: WebTheme.webWarning,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentGrid() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: ResponsiveGrid(
        children: [
          // Current Weather Card
          DashboardCard(
            title: 'Current Weather',
            icon: Icons.wb_sunny,
            iconColor: WebTheme.webWarning,
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData['temperature']}°C',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: WebTheme.webPrimary,
                          ),
                        ),
                        Text(
                          _weatherData['description'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: WebTheme.webSecondary,
                          ),
                        ),
                        Text(
                          'Feels like ${_weatherData['feelsLike']}°C',
                          style: const TextStyle(
                            fontSize: 14,
                            color: WebTheme.webSecondary,
                          ),
                        ),
                      ],
                    ),
                    WebIndicators.weatherCondition(
                      condition: _weatherData['description'],
                      size: 64,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    WebIndicators.temperatureIndicator(
                      temperature: _weatherData['temperature'],
                    ),
                    WebIndicators.connectionStatus(
                      isConnected: true,
                      message: 'Live Data',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Weather Details Card
          DashboardCard(
            title: 'Weather Details',
            icon: Icons.info_outline,
            content: Column(
              children: [
                _buildDetailRow('Pressure', '${_weatherData['pressure']} hPa'),
                _buildDetailRow('Visibility', '${_weatherData['visibility']} km'),
                _buildDetailRow('UV Index', '${_weatherData['uvIndex']}'),
                _buildDetailRow('Wind Speed', '${_weatherData['windSpeed']} km/h'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    if (_alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: DashboardCard(
        title: 'Weather Alerts',
        icon: Icons.warning,
        iconColor: WebTheme.webWarning,
        content: Column(
          children: _alerts.map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAlertColor(alert['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAlertColor(alert['type']).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getAlertIcon(alert['type']),
                    color: _getAlertColor(alert['type']),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert['message'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: WebTheme.webSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert['time'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: WebTheme.webSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildForecastSection() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: DashboardCard(
        title: '5-Day Forecast',
        icon: Icons.calendar_today,
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _forecast.map((day) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WebTheme.webPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: WebTheme.webPrimary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      day['day'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    WebIndicators.weatherCondition(
                      condition: day['condition'],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${day['high']}°',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: WebTheme.webPrimary,
                      ),
                    ),
                    Text(
                      '${day['low']}°',
                      style: const TextStyle(
                        fontSize: 14,
                        color: WebTheme.webSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day['precip']}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: WebTheme.webInfo,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: WebTheme.webSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return WebTheme.webWarning;
      case 'error':
        return WebTheme.webError;
      case 'info':
        return WebTheme.webInfo;
      default:
        return WebTheme.webSecondary;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      default:
        return Icons.help;
    }
  }
}
