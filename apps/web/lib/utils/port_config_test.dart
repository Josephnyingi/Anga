import 'api_config.dart';

/// 🧪 **Port Configuration Test**
/// 
/// This utility helps test and validate the API configuration
/// for the web application.
class PortConfigTest {
  static void runTest() {
    print("🧪 Running Port Configuration Test for Web App...");
    
    try {
      // Test API configuration
      ApiConfig.printConfigurationDetails();
      
      // Test connectivity
      _testConnectivity();
      
      print("✅ Port configuration test completed successfully");
    } catch (e) {
      print("❌ Port configuration test failed: $e");
    }
  }
  
  static Future<void> _testConnectivity() async {
    print("🔍 Testing backend connectivity...");
    
    try {
      final isConnected = await ApiConfig.testBackendConnectivity();
      if (isConnected) {
        print("✅ Backend connectivity test passed");
      } else {
        print("⚠️ Backend connectivity test failed - backend may not be running");
      }
    } catch (e) {
      print("❌ Backend connectivity test error: $e");
    }
  }
}
