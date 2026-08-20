import '../models/auth_tokens.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  /// POST /api/auth/signup/ — citizen registration. No JWT is returned.
  Future<User> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _client.postJson(
      ApiConfig.signup,
      authenticated: false,
      body: {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      },
    );
    _client.ensureSuccess(response);
    return User.fromJson(_client.decodeObject(response));
  }

  /// POST /api/auth/login/ — `identifier` is email or phone.
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.postJson(
      ApiConfig.login,
      authenticated: false,
      body: {
        'identifier': identifier,
        'password': password,
      },
    );
    final data = _client.decodeObject(response);
    final access = data['access']?.toString();
    final refresh = data['refresh']?.toString();
    if (access == null || refresh == null) {
      throw StateError('Login response did not include JWT tokens.');
    }
    await _client.tokenStorage.saveTokens(
      AuthTokens(access: access, refresh: refresh),
    );
    final userJson = data['user'];
    if (userJson is! Map) {
      throw StateError('Login response did not include a user object.');
    }
    final user = User.fromJson(Map<String, dynamic>.from(userJson));
    await _client.tokenStorage.saveUser(user);
    return user;
  }

  /// GET /api/auth/me/
  Future<User> fetchCurrentUser() async {
    final response = await _client.get(ApiConfig.me);
    final user = User.fromJson(_client.decodeObject(response));
    await _client.tokenStorage.saveUser(user);
    return user;
  }

  Future<User?> restoreSession() async {
    final tokens = await _client.tokenStorage.readTokens();
    if (tokens == null) {
      return null;
    }
    try {
      return await fetchCurrentUser();
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    await _client.tokenStorage.clear();
  }
}
