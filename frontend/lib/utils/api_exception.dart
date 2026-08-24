import 'dart:convert';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromBody(String body, {int? statusCode}) {
    return ApiException(_extract(body), statusCode: statusCode);
  }

  static String _extract(String body) {
    if (body.isEmpty) return 'Request failed.';
    try {
      final decoded = jsonDecode(body);
      if (decoded is String) return decoded;
      if (decoded is List) return decoded.map((e) => e.toString()).join('\n');
      if (decoded is Map) {
        if (decoded['detail'] != null) return decoded['detail'].toString();
        final parts = <String>[];
        decoded.forEach((key, value) {
          final text = value is List ? value.map((e) => e.toString()).join(', ') : value.toString();
          parts.add(key == 'non_field_errors' ? text : '$key: $text');
        });
        if (parts.isNotEmpty) return parts.join('\n');
      }
    } catch (_) {}
    return 'Request failed.';
  }

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
