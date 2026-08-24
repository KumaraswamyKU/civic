import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/auth_tokens.dart';
import '../utils/api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({TokenStorage? tokenStorage, http.Client? httpClient})
      : _tokens = tokenStorage ?? TokenStorage(),
        _http = httpClient ?? http.Client();

  final TokenStorage _tokens;
  final http.Client _http;

  TokenStorage get tokenStorage => _tokens;

  Future<http.Response> get(String path, {bool authenticated = true}) {
    return _send(method: 'GET', path: path, authenticated: authenticated);
  }

  Future<http.Response> postJson(String path, {Object? body, bool authenticated = true}) {
    return _send(method: 'POST', path: path, authenticated: authenticated, jsonBody: body);
  }

  Future<http.Response> patchJson(String path, {Object? body, bool authenticated = true}) {
    return _send(method: 'PATCH', path: path, authenticated: authenticated, jsonBody: body);
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    required bool authenticated,
    Object? jsonBody,
    bool isRetry = false,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (jsonBody != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (authenticated) {
      final access = await _tokens.readAccessToken();
      if (access != null && access.isNotEmpty) {
        headers['Authorization'] = 'Bearer $access';
      }
    }

    final uri = path.startsWith('http') ? Uri.parse(path) : ApiConfig.uri(path);
    final encoded = jsonBody == null ? null : jsonEncode(jsonBody);
    late http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _http.get(uri, headers: headers);
        case 'POST':
          response = await _http.post(uri, headers: headers, body: encoded);
        case 'PATCH':
          response = await _http.patch(uri, headers: headers, body: encoded);
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on http.ClientException catch (error) {
      throw ApiException('Could not reach the Civic server. ${error.message}');
    }

    if (authenticated && response.statusCode == 401 && !isRetry) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return _send(
          method: method,
          path: path,
          authenticated: authenticated,
          jsonBody: jsonBody,
          isRetry: true,
        );
      }
    }
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    final response = await _http.post(
      ApiConfig.uri(ApiConfig.tokenRefresh),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );
    if (response.statusCode != 200) {
      await _tokens.clear();
      return false;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return false;
    final access = decoded['access']?.toString();
    if (access == null || access.isEmpty) return false;
    final nextRefresh = decoded['refresh']?.toString() ?? refresh;
    await _tokens.saveTokens(AuthTokens(access: access, refresh: nextRefresh));
    return true;
  }

  Map<String, dynamic> decodeObject(http.Response response) {
    ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw ApiException('Unexpected JSON object.', statusCode: response.statusCode);
  }

  List<dynamic> decodeList(http.Response response) {
    ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['results'] is List) {
      return decoded['results'] as List;
    }
    throw ApiException('Unexpected JSON list.', statusCode: response.statusCode);
  }

  void ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw ApiException.fromBody(response.body, statusCode: response.statusCode);
  }
}
