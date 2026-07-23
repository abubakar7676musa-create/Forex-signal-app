import 'package:forex_signals_app/core/network/api_client.dart';
import 'package:forex_signals_app/core/storage/secure_storage.dart';
import 'package:forex_signals_app/models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient.instance;

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final json = await _client.post('/auth/register', data: {
      'email': email,
      'password': password,
      'full_name': fullName,
    });
    return UserModel.fromJson(json);
  }

  Future<UserModel> login({required String email, required String password}) async {
    final tokenJson = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await SecureStorage.instance.saveTokens(
      accessToken: tokenJson['access_token'],
      refreshToken: tokenJson['refresh_token'],
    );
    return getCurrentUser();
  }

  Future<UserModel> getCurrentUser() async {
    final json = await _client.get('/auth/me');
    return UserModel.fromJson(json);
  }

  Future<void> logout() async {
    await SecureStorage.instance.clear();
  }
}
