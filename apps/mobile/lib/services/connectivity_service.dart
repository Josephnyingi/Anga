import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/api_config.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Getters
  bool get isConnected => _isConnected;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  // Initialize the service
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _updateConnectionStatus(results);
        },
        onError: (error) {
          ApiConfig.errorPrint("Connectivity error: $error");
        },
      );

      ApiConfig.debugPrint("✅ Connectivity service initialized");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to initialize connectivity service: $e");
    }
  }

  // Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      ApiConfig.debugPrint("🌐 Connection status changed: ${_isConnected ? 'Connected' : 'Disconnected'}");
      _connectionStatusController.add(_isConnected);
    }
  }

  // Check if connected to internet
  Future<bool> checkInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      ApiConfig.errorPrint("❌ Error checking internet connection: $e");
      return false;
    }
  }

  // Get connection type
  Future<String> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.isEmpty || result.contains(ConnectivityResult.none)) {
        return 'None';
      }
      
      // Return the first available connection type
      if (result.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (result.contains(ConnectivityResult.mobile)) {
        return 'Mobile';
      } else if (result.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else if (result.contains(ConnectivityResult.vpn)) {
        return 'VPN';
      } else if (result.contains(ConnectivityResult.bluetooth)) {
        return 'Bluetooth';
      } else if (result.contains(ConnectivityResult.other)) {
        return 'Other';
      }
      
      return 'Unknown';
    } catch (e) {
      ApiConfig.errorPrint("❌ Error getting connection type: $e");
      return 'Unknown';
    }
  }

  // Wait for connection
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;

    try {
      await for (final connected in connectionStatus.timeout(timeout)) {
        if (connected) return true;
      }
      return false;
    } catch (e) {
      ApiConfig.errorPrint("❌ Timeout waiting for connection: $e");
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
} 