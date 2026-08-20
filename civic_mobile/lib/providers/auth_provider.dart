import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/app_services.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._services);

  final AppServices _services;

  AuthService get authService => _services.auth;
  AppServices get services => _services;

  User? _user;
  bool _restoring = true;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get restoring => _restoring;
  String? get error => _error;

  Future<void> restoreSession() async {
    _restoring = true;
    notifyListeners();
    _user = await _services.auth.restoreSession();
    _restoring = false;
    notifyListeners();
  }

  Future<void> login({required String identifier, required String password}) async {
    _error = null;
    notifyListeners();
    try {
      _user = await _services.auth.login(identifier: identifier, password: password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await _services.auth.signup(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _services.auth.logout();
    _user = null;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthProvider> {
  const AuthScope({
    super.key,
    required AuthProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AuthProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found');
    return scope!.notifier!;
  }
}
