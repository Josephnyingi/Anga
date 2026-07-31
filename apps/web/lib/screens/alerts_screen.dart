import 'package:flutter/material.dart';
import '../services/alerts_service.dart';
import '../utils/app_state.dart';

/// 🚨 **Alerts Screen for Web**
///
/// Real threshold-based early-warning alerts (heat, frost, flood, drought,
/// livestock heat stress) from the backend's /alerts/ endpoint.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<WeatherAlert> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alerts = await AlertsService.getAlerts(
        AppState.selectedLocation.toLowerCase(),
        phoneNumber: AppState.phoneNumber,
      );
      if (mounted) {
        setState(() => _alerts = alerts);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load alerts');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _dismiss(WeatherAlert alert) {
    setState(() => _alerts.removeWhere((a) => a.id == alert.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildMessage(Icons.error_outline, _error!);
    }

    if (_alerts.isEmpty) {
      return _buildMessage(
        Icons.notifications_none,
        'No alerts for ${AppState.selectedLocation} right now',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAlertColor(alert.severity),
              child: Icon(_getAlertIcon(alert.type), color: Colors.white),
            ),
            title: Text(
              _alertTitle(alert.type),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message),
                const SizedBox(height: 4),
                Text(
                  alert.date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss',
              onPressed: () => _dismiss(alert),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage(IconData icon, String text) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
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
}
