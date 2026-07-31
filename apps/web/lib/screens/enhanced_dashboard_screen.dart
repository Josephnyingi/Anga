import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/web_card.dart';
import '../widgets/web_animations.dart';
import '../widgets/web_loading_states.dart';
import '../widgets/web_indicators.dart';
import '../widgets/web_forms.dart';
import '../theme/web_theme.dart';
import '../services/live_weather_service.dart';
import '../services/forecast_service.dart';
import '../services/alerts_service.dart';
import '../services/notification_service.dart';
import '../services/geocode_service.dart';
import '../utils/app_state.dart';

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
  String _selectedLocation = AppState.selectedLocation;
  final TextEditingController _locationSearchController = TextEditingController();

  // Populated from the backend in _loadData(); empty/default until the
  // first fetch completes.
  Map<String, dynamic> _weatherData = {
    'temperature': null,
    'humidity': null,
    'windSpeed': null,
    'pressure': null,
    'uvIndex': null,
    'description': '—',
    'feelsLike': null,
    'rain': null,
  };

  List<Map<String, dynamic>> _forecast = [];
  List<Map<String, dynamic>> _alerts = [];

  // Alert ids already surfaced as a notification this session, so refreshing
  // the dashboard doesn't re-fire the same warning repeatedly.
  final Set<String> _notifiedAlertIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final location = _selectedLocation.toLowerCase();
    final lat = AppState.selectedLat;
    final lon = AppState.selectedLon;

    try {
      final results = await Future.wait([
        LiveWeatherService.getLiveWeather(location, lat: lat, lon: lon, label: _selectedLocation),
        ForecastService.getForecast(location, days: 5, lat: lat, lon: lon, label: _selectedLocation),
        AlertsService.getAlerts(location, phoneNumber: AppState.phoneNumber, lat: lat, lon: lon, label: _selectedLocation),
      ]);

      final live = results[0] as Map<String, dynamic>;
      final forecast = results[1] as List<ForecastDay>;
      final alerts = results[2] as List<WeatherAlert>;

      if (mounted) {
        setState(() {
          _weatherData = {
            'temperature': live['temperature'],
            'humidity': live['humidity'],
            'windSpeed': live['wind_speed'],
            'pressure': live['pressure'],
            'uvIndex': live['uv_index'],
            'description': live['description'] ?? '—',
            'feelsLike': live['feels_like'],
            'rain': live['precipitation'],
          };
          _forecast = forecast
              .map((d) => {
                    'day': _formatDayLabel(d.date),
                    'high': d.tempMax,
                    'low': d.tempMin,
                    'condition': d.description,
                    'precip': d.precipitationSum,
                  })
              .toList();
          _alerts = alerts
              .map((a) => {
                    'title': _alertTitle(a.type),
                    'message': a.message,
                    'type': a.severity == 'high' ? 'warning' : 'info',
                    'time': a.date,
                  })
              .toList();
        });
      }

      await _notifyNewAlerts(alerts);
    } catch (e) {
      debugPrint("❌ Dashboard load error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _notifyNewAlerts(List<WeatherAlert> alerts) async {
    for (final alert in alerts) {
      if (_notifiedAlertIds.contains(alert.id)) continue;
      _notifiedAlertIds.add(alert.id);
      await NotificationService().showWeatherAlert(
        title: '⚠️ Weather Alert — ${alert.location}',
        body: alert.message,
      );
    }
  }

  String _alertTitle(String type) {
    switch (type) {
      case 'heat':
        return 'Extreme Heat Warning';
      case 'frost':
        return 'Frost Warning';
      case 'flood':
        return 'Heavy Rain / Flood Risk';
      case 'drought':
        return 'Drought Risk';
      case 'livestock_heat_stress':
        return 'Livestock Heat Stress Risk';
      default:
        return 'Weather Alert';
    }
  }

  String _formatDayLabel(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final today = DateTime.now();
      final diff = DateTime(date.year, date.month, date.day)
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Tomorrow';
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadData();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
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

  void _onLocationSelected(LocationResult result) {
    setState(() {
      _selectedLocation = result.displayName;
      AppState.selectedLocation = result.displayName;
      AppState.selectedLat = result.lat;
      AppState.selectedLon = result.lon;
      _locationSearchController.text = result.displayName;
    });
    _loadData();
  }

  void _selectQuickLocation(String name) {
    setState(() {
      _selectedLocation = name;
      AppState.selectedLocation = name;
      // Clear lat/lon so the backend uses its machakos/vhembe whitelist path.
      AppState.selectedLat = null;
      AppState.selectedLon = null;
      _locationSearchController.clear();
    });
    _loadData();
  }

  Widget _quickLocationChip(String name) {
    final selected = _selectedLocation == name;
    return ChoiceChip(
      label: Text(name),
      selected: selected,
      onSelected: (_) => _selectQuickLocation(name),
      selectedColor: Colors.white,
      backgroundColor: Colors.white.withOpacity(0.15),
      labelStyle: TextStyle(color: selected ? WebTheme.webPrimary : Colors.white),
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
          // Location Selector - search any IGAD-country location, or quick-pick
          // the two original towns.
          TypeAheadField<LocationResult>(
            controller: _locationSearchController,
            suggestionsCallback: (search) => GeocodeService.search(search),
            itemBuilder: (context, result) => ListTile(
              leading: const Icon(Icons.location_on, color: WebTheme.webPrimary),
              title: Text(result.displayName),
              subtitle: result.admin1 != null ? Text(result.admin1!) : null,
            ),
            onSelected: (result) => _onLocationSelected(result),
            builder: (context, controller, focusNode) => TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search any location in Kenya, Uganda, Ethiopia...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _quickLocationChip('Machakos'),
              const SizedBox(width: 8),
              _quickLocationChip('Vhembe'),
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
                _buildDetailRow('Rain', '${_weatherData['rain']} mm'),
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
