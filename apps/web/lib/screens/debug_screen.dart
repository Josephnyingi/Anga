import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

/// 🐛 **Debug Screen for Web**
///
/// Real diagnostic information and live connectivity checks - every value
/// and action here reflects actual app/browser/backend state rather than
/// simulated placeholders.
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _ServiceStatus {
  final String label;
  final bool? connected; // null while checking
  final String detail;
  const _ServiceStatus(this.label, this.connected, this.detail);
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic> _systemInfo = {};
  List<_ServiceStatus> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
    _checkApiStatus();
  }

  void _loadSystemInfo() {
    final size = MediaQuery.of(context).size;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    setState(() {
      _systemInfo = {
        'appVersion': '1.0.0',
        'platform': 'Web',
        'userAgent': html.window.navigator.userAgent,
        'screenSize': '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)} @ ${dpr}x',
        'theme': Theme.of(context).brightness.name,
        'locale': html.window.navigator.language ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      };
    });
  }

  Future<void> _checkApiStatus() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthCheckUrl), headers: ApiConfig.defaultHeaders)
          // Render's free tier cold start can take 60-90s - a short timeout
          // here made a genuinely-up backend falsely report "Disconnected".
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _services = [
            _ServiceStatus('Backend API', true, 'HTTP ${response.statusCode}'),
            _ServiceStatus('Database', data['database'] == 'healthy', '${data['database']}'),
            _ServiceStatus('AI Assistant', data['ai_assistant_available'] == true,
                data['ai_assistant_available'] == true ? 'available' : 'unavailable'),
            _ServiceStatus('ML Models', data['ml_models_loaded'] == true,
                data['ml_models_loaded'] == true ? 'loaded' : 'not loaded'),
          ];
        });
      } else {
        setState(() {
          _services = [
            _ServiceStatus('Backend API', false, 'HTTP ${response.statusCode}'),
            const _ServiceStatus('Database', null, 'unknown - backend unreachable'),
            const _ServiceStatus('AI Assistant', null, 'unknown - backend unreachable'),
            const _ServiceStatus('ML Models', null, 'unknown - backend unreachable'),
          ];
        });
      }
    } catch (e) {
      setState(() {
        _services = [
          _ServiceStatus('Backend API', false, e.toString()),
          const _ServiceStatus('Database', null, 'unknown - backend unreachable'),
          const _ServiceStatus('AI Assistant', null, 'unknown - backend unreachable'),
          const _ServiceStatus('ML Models', null, 'unknown - backend unreachable'),
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            onPressed: () {
              _loadSystemInfo();
              _checkApiStatus();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                        _buildInfoRow(entry.key, entry.value.toString())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // API Status - a real GET /health call, not simulated
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'API Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_services.isEmpty && !_isLoading)
                      const Text('No data yet - tap refresh.'),
                    ..._services.map((s) => _buildStatusRow(s)),
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
                      label: const Text('Clear Image Cache'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _exportLogs,
                      icon: const Icon(Icons.download),
                      label: const Text('Export Debug Info'),
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

  Widget _buildStatusRow(_ServiceStatus s) {
    final icon = s.connected == null
        ? Icons.help_outline
        : (s.connected! ? Icons.check_circle : Icons.error);
    final color = s.connected == null
        ? Colors.grey
        : (s.connected! ? Colors.green : Colors.red);
    final label = s.connected == null ? 'Unknown' : (s.connected! ? 'Connected' : 'Disconnected');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(s.label),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text(s.detail, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _testAPI() async {
    final stopwatch = Stopwatch()..start();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Testing ${ApiConfig.healthCheckUrl}...')),
    );

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthCheckUrl), headers: ApiConfig.defaultHeaders)
          // Render's free tier cold start can take 60-90s - a short timeout
          // here made a genuinely-up backend falsely report "Disconnected".
          .timeout(const Duration(seconds: 60));
      stopwatch.stop();

      if (mounted) {
        final ok = response.statusCode == 200;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'API reachable - HTTP ${response.statusCode} in ${stopwatch.elapsedMilliseconds}ms'
                : 'API returned HTTP ${response.statusCode}'),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API unreachable: $e'), backgroundColor: Colors.red),
        );
      }
    }
    _checkApiStatus();
  }

  void _clearCache() {
    // The app's caching is server-side (Open-Meteo response cache on the
    // backend); the only real client-side cache is Flutter's image cache
    // (used by cached_network_image and asset images), so that's what this
    // actually clears rather than pretending to clear something it can't.
    final count = PaintingBinding.instance.imageCache.currentSize;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cleared $count cached image${count == 1 ? '' : 's'} from memory'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportLogs() {
    // There's no persistent app log buffer, so this exports the real debug
    // snapshot currently on screen (system info + last API check) as JSON,
    // rather than claiming to export logs that don't exist.
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'systemInfo': _systemInfo,
      'apiStatus': {
        for (final s in _services) s.label: {'connected': s.connected, 'detail': s.detail}
      },
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
    final blob = html.Blob([jsonStr], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'anga-debug-${DateTime.now().millisecondsSinceEpoch}.json')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debug info downloaded'), backgroundColor: Colors.green),
    );
  }
}
