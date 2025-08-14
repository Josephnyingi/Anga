import 'package:flutter/material.dart';
import '../utils/api_config.dart';

/// Debug widget to show API configuration and test connectivity
/// This widget is only visible in debug mode
class DebugConfigWidget extends StatefulWidget {
  const DebugConfigWidget({super.key});

  @override
  State<DebugConfigWidget> createState() => _DebugConfigWidgetState();
}

class _DebugConfigWidgetState extends State<DebugConfigWidget> {
  bool _isTesting = false;
  bool? _connectivityResult;

  @override
  void initState() {
    super.initState();
    // Print configuration details on init
    try {
      ApiConfig.printConfigurationDetails();
    } catch (e) {
      print('Error in debug widget init: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!ApiConfig.debugMode) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Debug Configuration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _testConnectivity,
                  tooltip: 'Test Backend Connectivity',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Base URL', ApiConfig.baseUrl),
            _buildInfoRow('Platform', _getPlatformInfo()),
            _buildInfoRow('Environment', 'Development'),
            if (_connectivityResult != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Backend Status',
                _connectivityResult! ? '✅ Connected' : '❌ Not Connected',
                color: _connectivityResult! ? Colors.green : Colors.red,
              ),
            ],
            if (_isTesting) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Testing connectivity...'),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'All Endpoints:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            ..._getEndpointsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnectivity() async {
    setState(() {
      _isTesting = true;
      _connectivityResult = null;
    });

    try {
      final result = await ApiConfig.testBackendConnectivity();
      setState(() {
        _connectivityResult = result;
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _connectivityResult = false;
        _isTesting = false;
      });
    }
  }

  String _getPlatformInfo() {
    try {
      final platformInfo = ApiConfig.platformInfo;
      final lines = platformInfo.split('\n');
      if (lines.length > 1) {
        return lines[1].trim();
      }
      return 'Unknown Platform';
    } catch (e) {
      return 'Error getting platform info';
    }
  }

  List<Widget> _getEndpointsList() {
    try {
      final endpoints = ApiConfig.allEndpoints;
      return endpoints.entries.map((entry) => 
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Text(
            '${entry.key.toString()}: ${entry.value.toString()}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ).toList();
    } catch (e) {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Text(
            'Error loading endpoints: $e',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.red),
          ),
        ),
      ];
    }
  }
} 