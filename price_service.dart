import 'package:forex_signals_app/core/network/api_client.dart';
import 'package:forex_signals_app/models/price_model.dart';

class PriceService {
  final ApiClient _client = ApiClient.instance;

  Future<List<PriceModel>> getAllPrices() async {
    final list = await _client.getList('/prices');
    return list.map((e) => PriceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PriceModel> getPrice(String pair) async {
    final json = await _client.get('/prices/$pair');
    return PriceModel.fromJson(json);
  }
}
