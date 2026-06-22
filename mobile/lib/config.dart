import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const String appName = 'HududRun';
  static const String appVersion = '1.0.0';

  static String get apiBaseUrl {
    if (kDebugMode) {
      if (kIsWeb) return 'http://localhost:3000';
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000';
      }
      return 'http://localhost:3000';
    }
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.hududrun.uz',
    );
  }
}
