import 'package:flutter/material.dart';
import '../utils/api_config.dart';
import '../utils/constants.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isTesting = false;
  bool? _connectivityResult;

  @override
  void initState() {
    super.initState();
    // Print configuration details on init
    try {
      ApiConfig.printConfigurationDetails();
    } catch (e) {
      print('Error in debug screen init: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Debug Configuration',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _testConnectivity,
            tooltip: 'Test Backend Connectivity',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuration Overview Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Configuration Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Base URL', ApiConfig.baseUrl),
                    _buildInfoRow('Platform', _getPlatformInfo()),
                    _buildInfoRow('Environment', 'Development'),
                    _buildInfoRow('Debug Mode', ApiConfig.debugMode.toString()),
                    _buildInfoRow('Timeout', '${ApiConfig.timeoutSeconds}s'),
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Endpoints Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'API Endpoints',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._getEndpointsList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Platform Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Platform Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getFullPlatformInfo(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testConnectivity,
                    icon: const Icon(Icons.wifi),
                    label: const Text("Test Connectivity"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyConfigToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy Config"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            width: 120,
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

  String _getFullPlatformInfo() {
    try {
      return ApiConfig.platformInfo;
    } catch (e) {
      return 'Error getting platform info: $e';
    }
  }

  List<Widget> _getEndpointsList() {
    try {
      final endpoints = ApiConfig.allEndpoints;
      return endpoints.entries.map((entry) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ).toList();
    } catch (e) {
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Error loading endpoints: $e',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.red),
          ),
        ),
      ];
    }
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

  void _copyConfigToClipboard() {
    // TODO: Implement clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 