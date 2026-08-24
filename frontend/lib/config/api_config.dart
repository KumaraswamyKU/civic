import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnvironment.isNotEmpty) {
      return _stripTrailingSlash(_fromEnvironment);
    }
    return _stripTrailingSlash(_defaultDevBaseUrl);
  }

  static String get _defaultDevBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static String _stripTrailingSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }

  static const String signup = '/api/auth/signup/';
  static const String login = '/api/auth/login/';
  static const String me = '/api/auth/me/';
  static const String tokenRefresh = '/api/auth/token/refresh/';
  static const String departments = '/api/departments/';
  static const String complaints = '/api/complaints/';
  static const String reportSummary = '/api/reports/summary/';
  static const String reportExportCsv = '/api/reports/export/csv/';

  static String complaintDetail(int id) => '/api/complaints/$id/';
  static String complaintStatus(int id) => '/api/complaints/$id/status/';
  static String complaintHistory(int id) => '/api/complaints/$id/history/';

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }
}
