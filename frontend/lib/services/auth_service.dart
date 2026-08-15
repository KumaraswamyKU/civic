import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception(_extractError(res.body));
    }
  }

  /// identifier: registered email OR phone number
  Future<AppUser> login({required String identifier, required String password}) async {
    final res = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception(_extractError(res.body));
    }
    final data = jsonDecode(res.body);
    await _saveTokens(data['access'], data['refresh']);
    return AppUser.fromJson(data['user']);
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  Future<AppUser?> fetchCurrentUser() async {
    final token = await getAccessToken();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse(ApiConfig.me),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) return null;
    return AppUser.fromJson(jsonDecode(res.body));
  }

  String _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }
}
