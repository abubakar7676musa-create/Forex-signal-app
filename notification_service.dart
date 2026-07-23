import 'package:forex_signals_app/core/network/api_client.dart';
import 'package:forex_signals_app/models/notification_model.dart';

class NotificationService {
  final ApiClient _client = ApiClient.instance;

  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final json = await _client.get('/notifications', query: {'limit': limit});
    final items = json['items'] as List<dynamic>? ?? [];
    return items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
