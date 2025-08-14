import 'dart:async';
import 'dart:developer' as developer;
import '../utils/api_config.dart';
import '../utils/environment_config.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _metrics = {};
  final List<String> _logs = [];
  bool _isEnabled = true;

  // Performance metrics
  int _apiCallCount = 0;
  int _apiErrorCount = 0;
  int _cacheHitCount = 0;
  int _cacheMissCount = 0;
  DateTime? _appStartTime;

  // Getters
  bool get isEnabled => _isEnabled;
  int get apiCallCount => _apiCallCount;
  int get apiErrorCount => _apiErrorCount;
  int get cacheHitCount => _cacheHitCount;
  int get cacheMissCount => _cacheMissCount;
  List<String> get logs => List.unmodifiable(_logs);

  // Initialize the service
  void initialize() {
    _appStartTime = DateTime.now();
    _isEnabled = EnvironmentConfig.enableLogging;
    
    if (_isEnabled) {
      ApiConfig.debugPrint("✅ Performance monitoring initialized");
    }
  }

  // Start timing an operation
  void startTimer(String operation) {
    if (!_isEnabled) return;
    
    _timers[operation] = Stopwatch()..start();
    _log('⏱️ Started timing: $operation');
  }

  // Stop timing an operation
  Duration? stopTimer(String operation) {
    if (!_isEnabled) return null;
    
    final timer = _timers.remove(operation);
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;
      
      // Store metric
      _metrics.putIfAbsent(operation, () => []).add(duration);
      
      _log('⏱️ Completed: $operation in ${duration.inMilliseconds}ms');
      
      // Log slow operations
      if (duration.inMilliseconds > 1000) {
        _log('🐌 Slow operation detected: $operation took ${duration.inMilliseconds}ms');
      }
      
      return duration;
    }
    return null;
  }

  // Track API call
  void trackApiCall(String endpoint, {bool isSuccess = true}) {
    if (!_isEnabled) return;
    
    _apiCallCount++;
    if (!isSuccess) {
      _apiErrorCount++;
    }
    
    _log('🌐 API call: $endpoint (${isSuccess ? 'success' : 'error'})');
  }

  // Track cache operation
  void trackCacheOperation(String operation, {bool isHit = true}) {
    if (!_isEnabled) return;
    
    if (isHit) {
      _cacheHitCount++;
    } else {
      _cacheMissCount++;
    }
    
    _log('💾 Cache $operation: ${isHit ? 'hit' : 'miss'}');
  }

  // Track memory usage
  void trackMemoryUsage() {
    if (!_isEnabled) return;
    
    // This is a simplified memory tracking
    // In a real app, you might use platform-specific APIs
    _log('🧠 Memory check performed');
  }

  // Track widget rebuild
  void trackWidgetRebuild(String widgetName) {
    if (!_isEnabled) return;
    
    _log('🔄 Widget rebuilt: $widgetName');
  }

  // Track navigation
  void trackNavigation(String from, String to) {
    if (!_isEnabled) return;
    
    _log('🧭 Navigation: $from → $to');
  }

  // Track user interaction
  void trackUserInteraction(String action) {
    if (!_isEnabled) return;
    
    _log('👆 User interaction: $action');
  }

  // Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final uptime = _appStartTime != null 
        ? DateTime.now().difference(_appStartTime!)
        : Duration.zero;

    final apiSuccessRate = _apiCallCount > 0 
        ? ((_apiCallCount - _apiErrorCount) / _apiCallCount * 100).toStringAsFixed(1)
        : '0.0';

    final cacheHitRate = (_cacheHitCount + _cacheMissCount) > 0
        ? (_cacheHitCount / (_cacheHitCount + _cacheMissCount) * 100).toStringAsFixed(1)
        : '0.0';

    final averageMetrics = <String, double>{};
    _metrics.forEach((operation, durations) {
      if (durations.isNotEmpty) {
        final average = durations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / durations.length;
        averageMetrics[operation] = average;
      }
    });

    return {
      'uptime_seconds': uptime.inSeconds,
      'api_calls': _apiCallCount,
      'api_errors': _apiErrorCount,
      'api_success_rate': '$apiSuccessRate%',
      'cache_hits': _cacheHitCount,
      'cache_misses': _cacheMissCount,
      'cache_hit_rate': '$cacheHitRate%',
      'average_metrics': averageMetrics,
      'total_logs': _logs.length,
    };
  }

  // Get slow operations
  List<Map<String, dynamic>> getSlowOperations({int thresholdMs = 1000}) {
    final slowOps = <Map<String, dynamic>>[];
    
    _metrics.forEach((operation, durations) {
      final slowDurations = durations.where((d) => d.inMilliseconds > thresholdMs).toList();
      if (slowDurations.isNotEmpty) {
        slowOps.add({
          'operation': operation,
          'count': slowDurations.length,
          'average_ms': slowDurations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / slowDurations.length,
          'max_ms': slowDurations.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b),
        });
      }
    });
    
    return slowOps;
  }

  // Get recent logs
  List<String> getRecentLogs({int count = 50}) {
    if (_logs.length <= count) return _logs;
    return _logs.sublist(_logs.length - count);
  }

  // Clear logs
  void clearLogs() {
    _logs.clear();
    _log('🗑️ Performance logs cleared');
  }

  // Clear metrics
  void clearMetrics() {
    _metrics.clear();
    _timers.clear();
    _apiCallCount = 0;
    _apiErrorCount = 0;
    _cacheHitCount = 0;
    _cacheMissCount = 0;
    _log('🗑️ Performance metrics cleared');
  }

  // Enable/disable monitoring
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    _log('${enabled ? '✅' : '❌'} Performance monitoring ${enabled ? 'enabled' : 'disabled'}');
  }

  // Log performance event
  void _log(String message) {
    if (!_isEnabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message';
    
    _logs.add(logEntry);
    
    // Keep only last 1000 logs
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }
    
    // Also log to console in debug mode
    if (EnvironmentConfig.enableDebugMode) {
      developer.log(logEntry, name: 'Performance');
    }
  }

  // Dispose resources
  void dispose() {
    _timers.clear();
    _metrics.clear();
    _logs.clear();
  }
} 