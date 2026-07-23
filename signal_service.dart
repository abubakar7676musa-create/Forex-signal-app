import 'package:forex_signals_app/core/network/api_client.dart';
import 'package:forex_signals_app/models/signal_model.dart';

class SignalService {
  final ApiClient _client = ApiClient.instance;

  Future<List<SignalModel>> getSignals({String? pair, String? direction, int limit = 50, int offset = 0}) async {
    final json = await _client.get('/signals', query: {
      if (pair != null) 'pair': pair,
      if (direction != null) 'direction': direction,
      'limit': limit,
      'offset': offset,
    });
    final items = json['items'] as List<dynamic>? ?? [];
    return items.map((e) => SignalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SignalModel>> getLatestSignals({int limit = 10}) async {
    final json = await _client.get('/signals/latest', query: {'limit': limit});
    final items = json['items'] as List<dynamic>? ?? [];
    return items.map((e) => SignalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SignalModel>> getFavoriteSignals({int limit = 50}) async {
    final json = await _client.get('/signals/favorites', query: {'limit': limit});
    final items = json['items'] as List<dynamic>? ?? [];
    return items.map((e) => SignalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SignalModel> getSignalById(String id) async {
    final json = await _client.get('/signals/$id');
    return SignalModel.fromJson(json);
  }
}
