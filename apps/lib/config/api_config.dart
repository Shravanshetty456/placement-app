import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    final override = _normalize(_apiBaseUrlOverride);
    if (override.isNotEmpty) {
      return override;
    }

    if (kIsWeb) {
      final scheme = Uri.base.scheme.isNotEmpty ? Uri.base.scheme : 'http';
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return '$scheme://$host:3000';
    }

    // Android emulators need 10.0.2.2 to reach the host machine.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://127.0.0.1:3000';
  }

  static String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
