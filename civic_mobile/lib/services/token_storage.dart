import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_tokens.dart';
import '../models/user.dart';

class TokenStorage {
  static const _accessKey = 'civic_access_token';
  static const _refreshKey = 'civic_refresh_token';
  static const _userKey = 'civic_user_json';

  Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, tokens.access);
    await prefs.setString(_refreshKey, tokens.refresh);
  }

  Future<AuthTokens?> readTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessKey);
    final refresh = prefs.getString(_refreshKey);
    if (access == null || refresh == null || access.isEmpty || refresh.isEmpty) {
      return null;
    }
    return AuthTokens(access: access, refresh: refresh);
  }

  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return User.fromJson(decoded);
    }
    if (decoded is Map) {
      return User.fromJson(Map<String, dynamic>.from(decoded));
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userKey);
  }
}
