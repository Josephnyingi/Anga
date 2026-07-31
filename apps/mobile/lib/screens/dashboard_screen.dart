import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_state.dart';
import '../services/live_weather_service.dart';
import '../services/forecast_service.dart';
import '../services/alerts_service.dart';
import '../services/notification_service.dart';

/// Dashboard: live weather, a 5-day forecast, and active alerts for the
/// farmer's selected location. Same data sources and alert-notification
/// behavior as the web app's dashboard (LiveWeatherService, ForecastService,
/// AlertsService, NotificationService), styled to match this app's existing
/// plain-Material screens rather than web's separate widget library.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

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
  // doesn't re-fire the same warning repeatedly.
  final Set<String> _notifiedAlertIds = {};

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  /// Public so main_screen.dart's refresh button can trigger a reload.
  Future<void> fetchWeather() async {
    setState(() => _isLoading = true);

    final location = AppState.selectedLocation.toLowerCase();

    try {
      final results = await Future.wait([
        LiveWeatherService.getLiveWeather(location),
        ForecastService.getForecast(location, days: 5),
        AlertsService.getAlerts(location, phoneNumber: AppState.phoneNumber),
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
                    'severity': a.severity,
                    'time': a.date,
                    'type': a.type,
                  })
              .toList();
        });
      }

      if (AppState.enableExtremeAlerts) {
        await _notifyNewAlerts(alerts);
      }
    } catch (e) {
      debugPrint("❌ Dashboard load error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  IconData _alertIcon(String type) {
    switch (type) {
      case 'heat':
        return Icons.thermostat;
      case 'frost':
        return Icons.ac_unit;
      case 'flood':
        return Icons.water_drop;
      case 'drought':
        return Icons.grain;
      case 'livestock_heat_stress':
        return Icons.pets;
      default:
        return Icons.warning;
    }
  }

  Color _alertColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationHeader(isDarkMode),
                    const SizedBox(height: 16),
                    _buildCurrentWeatherCard(isDarkMode),
                    const SizedBox(height: 16),
                    _buildQuickStatsRow(),
                    if (_alerts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAlertsCard(isDarkMode),
                    ],
                    const SizedBox(height: 16),
                    _buildForecastCard(isDarkMode),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLocationHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Weather overview for ${AppState.selectedLocation}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        DropdownButton<String>(
          value: AppState.selectedLocation,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'Machakos', child: Text('Machakos')),
            DropdownMenuItem(value: 'Vhembe', child: Text('Vhembe')),
          ],
          onChanged: (value) {
            setState(() => AppState.selectedLocation = value!);
            fetchWeather();
          },
        ),
      ],
    );
  }

  Widget _buildCurrentWeatherCard(bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weatherData['temperature'] ?? '--'}°C',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  '${_weatherData['description']}',
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.grey.shade700),
                ),
                Text(
                  'Feels like ${_weatherData['feelsLike'] ?? '--'}°C',
                  style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white54 : Colors.grey.shade600),
                ),
              ],
            ),
            Icon(Icons.wb_sunny, size: 56, color: secondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('Humidity', '${_weatherData['humidity'] ?? '--'}%', Icons.water_drop, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Wind', '${_weatherData['windSpeed'] ?? '--'} km/h', Icons.air, secondaryColor)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('UV Index', '${_weatherData['uvIndex'] ?? '--'}', Icons.wb_sunny, Colors.orange)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Weather Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ..._alerts.map((alert) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _alertColor(alert['severity']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _alertColor(alert['severity']).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(_alertIcon(alert['type']), color: _alertColor(alert['severity'])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(alert['message'], style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('5-Day Forecast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final day = _forecast[index];
                  return Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day['day'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('${day['high']}°', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                        Text('${day['low']}°', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          day['condition'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
