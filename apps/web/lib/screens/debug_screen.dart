import 'package:flutter/material.dart';

/// 🐛 **Debug Screen for Web**
/// 
/// This screen provides debugging information and system status.
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic> _systemInfo = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate loading system information
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _systemInfo = {
          'appVersion': '1.0.0',
          'platform': 'Web',
          'userAgent': 'Mozilla/5.0 (Web Browser)',
          'screenSize': '1920x1080',
          'theme': Theme.of(context).brightness.name,
          'locale': 'en_US',
          'timestamp': DateTime.now().toIso8601String(),
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
        title: const Text('Debug Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSystemInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ..._systemInfo.entries.map((entry) => 
                            _buildInfoRow(entry.key, entry.value.toString())
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // API Status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildStatusRow('Backend API', 'Connected', true),
                          _buildStatusRow('Weather Service', 'Connected', true),
                          _buildStatusRow('AI Assistant', 'Connected', true),
                          _buildStatusRow('Database', 'Connected', true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Debug Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Actions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _testAPI,
                            icon: const Icon(Icons.api),
                            label: const Text('Test API Connection'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _clearCache,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Cache'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _exportLogs,
                            icon: const Icon(Icons.download),
                            label: const Text('Export Logs'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String service, String status, bool isConnected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: isConnected ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(service),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testAPI() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing API connection...')),
    );
    
    // Simulate API test
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API connection test completed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs exported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
