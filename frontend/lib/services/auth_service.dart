import '../models/auth_tokens.dart';
import '../models/user.dart';
import '../utils/api_exception.dart';
import 'api_client.dart';
import '../config/api_config.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<void> signup({
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
  }

  Future<AppUser> login({required String identifier, required String password}) async {
    final response = await _client.postJson(
      ApiConfig.login,
      authenticated: false,
      body: {'identifier': identifier, 'password': password},
    );
    final data = _client.decodeObject(response);
    final access = data['access']?.toString();
    final refresh = data['refresh']?.toString();
    if (access == null || refresh == null) {
      throw ApiException('Login did not return tokens.');
    }
    await _client.tokenStorage.saveTokens(AuthTokens(access: access, refresh: refresh));
    final userJson = data['user'];
    if (userJson is! Map) {
      throw ApiException('Login did not return a user.');
    }
    final user = AppUser.fromJson(Map<String, dynamic>.from(userJson));
    await _client.tokenStorage.saveUser(user);
    return user;
  }

  Future<AppUser?> fetchCurrentUser() async {
    final token = await _client.tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _client.get(ApiConfig.me);
      final user = AppUser.fromJson(_client.decodeObject(response));
      await _client.tokenStorage.saveUser(user);
      return user;
    } catch (_) {
      return _client.tokenStorage.readUser();
    }
  }

  Future<void> logout() => _client.tokenStorage.clear();
}
