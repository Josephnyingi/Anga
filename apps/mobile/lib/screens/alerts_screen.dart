import 'package:flutter/material.dart';
import '../utils/constants.dart';   // For colors and alert types
import '../utils/app_state.dart';   // ✅ In-memory state
import '../services/alerts_service.dart';
import '../services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> alerts = [];
  bool _isLoading = true;

  // Alert ids already surfaced as a notification this session, so refreshing
  // doesn't re-fire the same warning repeatedly.
  final Set<String> _notifiedAlertIds = {};

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);

    try {
      final location = AppState.selectedLocation.toLowerCase();
      final raw = await AlertsService.getAlerts(location, phoneNumber: AppState.phoneNumber);

      if (mounted) {
        setState(() {
          alerts = raw.map(_mapAlert).toList();
        });
      }

      for (final alert in raw) {
        if (_notifiedAlertIds.contains(alert.id)) continue;
        _notifiedAlertIds.add(alert.id);
        await NotificationService().showWeatherAlert(
          title: '⚠️ Weather Alert — ${alert.location}',
          body: alert.message,
        );
      }
    } catch (e) {
      print("❌ Alerts fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _mapAlert(WeatherAlert a) {
    const typeMeta = {
      'heat': {'title': 'Extreme Heat', 'severity': 'Extreme Heat', 'icon': Icons.thermostat},
      'frost': {'title': 'Frost Risk', 'severity': 'Frost Risk', 'icon': Icons.ac_unit},
      'flood': {'title': 'Heavy Rainfall', 'severity': 'Flood Risk', 'icon': Icons.water_drop},
      'drought': {'title': 'Drought Risk', 'severity': 'Drought Risk', 'icon': Icons.grain},
      'livestock_heat_stress': {
        'title': 'Livestock Heat Stress',
        'severity': 'Livestock Heat Stress',
        'icon': Icons.pets,
      },
    };
    final meta = typeMeta[a.type] ??
        {'title': 'Weather Alert', 'severity': a.type, 'icon': Icons.warning};

    return {
      "type": meta['title'],
      "location": a.location,
      "severity": meta['severity'],
      "date": a.date,
      "time": "",
      "description": a.message,
      "icon": meta['icon'],
      "priority": a.severity == 'high' ? 'high' : 'medium',
    };
  }

  /// Get color based on alert severity
  Color _getAlertColor(String severity, String priority) {
    if (priority == "high") {
      switch (severity) {
        case "Extreme Heat":
          return Colors.red.shade700;
        case "Flood Risk":
          return Colors.orange.shade700;
        case "Strong Winds":
          return Colors.purple.shade700;
        case "Frost Risk":
          return Colors.lightBlue.shade700;
        case "Livestock Heat Stress":
          return Colors.deepOrange.shade700;
        default:
          return Colors.red.shade600;
      }
    } else {
      switch (severity) {
        case "Extreme Heat":
          return Colors.orange.shade600;
        case "Flood Risk":
          return Colors.blue.shade600;
        case "Strong Winds":
          return Colors.indigo.shade600;
        case "Frost Risk":
          return Colors.lightBlue.shade400;
        case "Drought Risk":
          return Colors.brown.shade400;
        case "Livestock Heat Stress":
          return Colors.deepOrange.shade400;
        default:
          return Colors.grey.shade600;
      }
    }
  }

  /// Get priority badge color
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Weather Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
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
              _loadAlerts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing alerts...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section with stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Alert notifications toggle
                SwitchListTile(
                  title: const Text("Enable Alert Notifications", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Get real-time severe weather alerts"),
                  value: AppState.enableExtremeAlerts,
                  onChanged: (value) {
                    setState(() {
                      AppState.enableExtremeAlerts = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Alert notifications enabled' : 'Alert notifications disabled'
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Alert statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard("Active Alerts", "${alerts.length}", Icons.warning, Colors.orange),
                    _buildStatCard("High Priority", "${alerts.where((a) => a["priority"] == "high").length}", Icons.priority_high, Colors.red),
                    _buildStatCard("Locations", "${alerts.map((a) => a["location"]).toSet().length}", Icons.location_on, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          
          // Alerts list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : alerts.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return _buildAlertCard(alert, isDarkMode);
                        },
                      )
                    : _buildEmptyState(isDarkMode),
          ),
        ],
      ),
      // Add floating action button for adding custom alerts
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddAlertDialog();
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Alert', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, bool isDarkMode) {
    final alertColor = _getAlertColor(alert["severity"], alert["priority"]);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                alertColor,
                alertColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        alert["icon"],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert["type"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            alert["location"],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(alert["priority"]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert["priority"].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  alert["description"],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Footer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${alert["date"]} at ${alert["time"]}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                          onPressed: () => _showAlertDetails(alert),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white, size: 20),
                          onPressed: () => _handleAlertAction('share', alert),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: () => _handleAlertAction('dismiss', alert),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No weather alerts at the moment",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll be notified when severe weather is detected",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Alerts'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show alert details dialog
  void _showAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert["type"]!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${alert["location"]}'),
            const SizedBox(height: 8),
            Text('Severity: ${alert["severity"]}'),
            const SizedBox(height: 8),
            Text('Date: ${alert["date"]}'),
            const SizedBox(height: 16),
            const Text(
              'This alert indicates severe weather conditions that may affect your area. Please take necessary precautions.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAlertAction('share', alert);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  /// Handle alert actions
  void _handleAlertAction(String action, Map<String, dynamic> alert) {
    switch (action) {
      case 'details':
        _showAlertDetails(alert);
        break;
      case 'share':
        _shareAlert(alert);
        break;
      case 'dismiss':
        _dismissAlert(alert);
        break;
    }
  }

  /// Share alert
  void _shareAlert(Map<String, dynamic> alert) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing alert: ${alert["type"]}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Dismiss alert
  void _dismissAlert(Map<String, dynamic> alert) {
    // TODO: Implement dismiss functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert dismissed: ${alert["type"]}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show add alert dialog
  void _showAddAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Alert'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This feature allows you to set custom weather alerts for specific conditions.'),
            SizedBox(height: 16),
            Text('Coming soon...', style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Alerts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter alerts by severity, location, or date range.'),
            SizedBox(height: 16),
            Text('Coming soon...', style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
