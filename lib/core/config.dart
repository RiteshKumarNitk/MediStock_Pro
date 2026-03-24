import 'package:flutter/foundation.dart';

class AppConfig {
  /// Set this to true to force using the Live backend in Debug mode
  static const bool forceLive = false;

  /// Check if the app is running in Live mode
  static bool get isLive => kReleaseMode || forceLive;

  /// Get the base URL for the API
  static String get baseUrl {
    if (isLive) {
      return 'https://innovatex-technology.com/api/medistock';
    }
    if (kIsWeb) {
      return 'http://localhost:3000/api/medistock';
    }
    // Android emulator loopback IP. 
    // If using a physical device, change this to your computer's IP
    return 'http://10.0.2.2:3000/api/medistock';
  }
}
