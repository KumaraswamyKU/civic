import 'dart:convert';

/// Maps Django REST Framework / SimpleJWT error bodies into a readable message.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  factory ApiException.fromBody(String body, {int? statusCode}) {
    return ApiException(_extract(body), statusCode: statusCode, body: body);
  }

  static String _extract(String body) {
    if (body.isEmpty) {
      return 'Request failed.';
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is String) {
        return decoded;
      }
      if (decoded is List) {
        return decoded.map((e) => e.toString()).join('\n');
      }
      if (decoded is Map) {
        if (decoded['detail'] != null) {
          return decoded['detail'].toString();
        }
        final parts = <String>[];
        decoded.forEach((key, value) {
          final text = value is List
              ? value.map((e) => e.toString()).join(', ')
              : value.toString();
          if (key == 'non_field_errors') {
            parts.add(text);
          } else {
            parts.add('$key: $text');
          }
        });
        if (parts.isNotEmpty) {
          return parts.join('\n');
        }
      }
    } catch (_) {
      // Non-JSON body (e.g. HTML error page).
    }
    return 'Request failed.';
  }

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
