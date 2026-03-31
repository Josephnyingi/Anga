/// ⚡ **Performance Service for Web**
/// 
/// This service handles performance monitoring for the web application.
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  /// Initialize the performance service
  void initialize() {
    print("⚡ Performance service initialized for web");
  }

  /// Start performance monitoring
  void startMonitoring() {
    print("⚡ Performance monitoring started for web");
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    print("⚡ Performance monitoring stopped for web");
  }

  /// Log performance metric
  void logMetric(String name, double value) {
    print("⚡ Performance metric: $name = $value");
  }

  /// Dispose resources
  void dispose() {
    print("⚡ Performance service disposed");
  }
}
