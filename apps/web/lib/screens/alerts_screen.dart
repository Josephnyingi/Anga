import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/alerts_service.dart';
import '../utils/app_state.dart';
import '../theme.dart';
import '../widgets/app_toast.dart';

/// Real threshold-based early-warning alerts (heat, frost, flood, drought,
/// livestock heat stress) from the backend's /alerts/ endpoint, with
/// severity/type filtering and an alert-notifications toggle.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class AlertSeverityFilter {
  static const all = 'all';
  static const high = 'high';
  static const medium = 'medium';
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<WeatherAlert> _alerts = [];
  bool _isLoading = true;
  String? _error;
  String _severityFilter = AlertSeverityFilter.all;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    // This screen is kept alive by the bottom nav's IndexedStack, so it
    // won't naturally rebuild when another tab changes the location -
    // without this listener it keeps showing whichever location was
    // selected the first time this tab was ever opened.
    AppState.selectedLocationNotifier.addListener(_loadAlerts);
  }

  @override
  void dispose() {
    AppState.selectedLocationNotifier.removeListener(_loadAlerts);
    super.dispose();
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
      if (mounted) setState(() => _alerts = alerts);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load alerts');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _dismiss(WeatherAlert alert) {
    setState(() => _alerts.removeWhere((a) => a.id == alert.id));
  }

  void _shareAlert(WeatherAlert alert) {
    final text = '${_alertTitle(alert.type)} — ${alert.message} (${alert.location}, ${alert.date})';
    Clipboard.setData(ClipboardData(text: text));
    showAppToast(context, 'Alert copied to clipboard');
  }

  List<WeatherAlert> get _filteredAlerts {
    if (_severityFilter == AlertSeverityFilter.all) return _alerts;
    return _alerts.where((a) => a.severity == _severityFilter).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Severity'),
        children: [
          _filterOption('All Alerts', AlertSeverityFilter.all),
          _filterOption('High Priority', AlertSeverityFilter.high),
          _filterOption('Medium Priority', AlertSeverityFilter.medium),
        ],
      ),
    );
  }

  Widget _filterOption(String label, String value) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() => _severityFilter = value);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          if (_severityFilter == value) const Icon(Icons.check, size: 18, color: AppTheme.primaryColor),
          if (_severityFilter == value) const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), tooltip: 'Filter', onPressed: _showFilterDialog),
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: _loadAlerts),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: _buildBody(isDarkMode),
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatsHeader(isDarkMode),
        const SizedBox(height: 16),
        if (_error != null)
          _buildMessage(Icons.error_outline, _error!)
        else if (_filteredAlerts.isEmpty)
          _buildMessage(
            Icons.notifications_none,
            _alerts.isEmpty
                ? 'No alerts for ${AppState.selectedLocation} right now'
                : 'No alerts match this filter',
          )
        else
          ..._filteredAlerts.map((alert) => _buildAlertCard(alert, isDarkMode)),
      ],
    );
  }

  Widget _buildStatsHeader(bool isDarkMode) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Alert Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Get real-time severe weather alerts'),
              value: AppState.enableExtremeAlerts,
              onChanged: (value) => setState(() => AppState.enableExtremeAlerts = value),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard('Active', '${_alerts.length}', Icons.warning, Colors.orange),
                _statCard('High Priority', '${_alerts.where((a) => a.severity == 'high').length}', Icons.priority_high, Colors.red),
                _statCard('Location', AppState.selectedLocation, Icons.location_on, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(WeatherAlert alert, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _getAlertColor(alert.severity),
              child: Icon(_getAlertIcon(alert.type), color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_alertTitle(alert.type), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(alert.message),
                  const SizedBox(height: 4),
                  Text(alert.date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  tooltip: 'Share',
                  onPressed: () => _shareAlert(alert),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Dismiss',
                  onPressed: () => _dismiss(alert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.grey)),
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
