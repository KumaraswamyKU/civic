import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/app_services.dart';

class AuthController extends ChangeNotifier {
  AuthController(this.services);

  final AppServices services;

  AppUser? user;
  bool restoring = true;

  Future<void> restore() async {
    restoring = true;
    notifyListeners();
    user = await services.auth.fetchCurrentUser();
    restoring = false;
    notifyListeners();
  }

  Future<void> login({required String identifier, required String password}) async {
    user = await services.auth.login(identifier: identifier, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await services.auth.logout();
    user = null;
    notifyListeners();
  }
}
