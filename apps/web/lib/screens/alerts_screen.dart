import 'package:flutter/material.dart';

/// 🚨 **Alerts Screen for Web**
/// 
/// This screen displays weather alerts and notifications.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'High Temperature Warning',
      'message': 'Temperatures are expected to reach 35°C today. Stay hydrated!',
      'type': 'warning',
      'time': '2 hours ago',
      'icon': Icons.warning,
    },
    {
      'title': 'Rain Forecast',
      'message': 'Light rain expected tomorrow morning. Plan outdoor activities accordingly.',
      'type': 'info',
      'time': '5 hours ago',
      'icon': Icons.cloud,
    },
    {
      'title': 'Farming Advisory',
      'message': 'Good conditions for planting maize. Soil moisture is optimal.',
      'type': 'success',
      'time': '1 day ago',
      'icon': Icons.agriculture,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No alerts at the moment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getAlertColor(alert['type']),
                      child: Icon(
                        alert['icon'],
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      alert['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alert['message']),
                        const SizedBox(height: 4),
                        Text(
                          alert['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showAlertOptions(alert);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  void _showAlertOptions(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(alert);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Alert'),
              onTap: () {
                Navigator.pop(context);
                _deleteAlert(alert);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markAsRead(Map<String, dynamic> alert) {
    // Implement mark as read functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert marked as read')),
    );
  }

  void _deleteAlert(Map<String, dynamic> alert) {
    setState(() {
      _alerts.remove(alert);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert deleted')),
    );
  }
}
