import 'package:forex_signals_app/core/network/api_client.dart';
import 'package:forex_signals_app/models/user_model.dart';

class UserService {
  final ApiClient _client = ApiClient.instance;

  Future<UserModel> getProfile() async {
    final json = await _client.get('/users/me');
    return UserModel.fromJson(json);
  }

  Future<UserModel> updateProfile({String? fullName, List<String>? favoritePairs}) async {
    final json = await _client.patch('/users/me', data: {
      if (fullName != null) 'full_name': fullName,
      if (favoritePairs != null) 'favorite_pairs': favoritePairs,
    });
    return UserModel.fromJson(json);
  }

  Future<void> updateFcmToken(String token) async {
    await _client.post('/users/me/fcm-token', data: {'fcm_token': token});
  }

  Future<void> deleteAccount() async {
    await _client.delete('/users/me');
  }
}
