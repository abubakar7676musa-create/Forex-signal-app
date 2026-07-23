import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:forex_signals_app/core/constants/app_constants.dart';
import 'package:forex_signals_app/core/network/api_exception.dart';
import 'package:forex_signals_app/models/price_model.dart';
import 'package:forex_signals_app/services/price_service.dart';

class PriceProvider extends ChangeNotifier {
  final PriceService _priceService = PriceService();

  List<PriceModel> prices = [];
  bool isLoading = false;
  String? errorMessage;
  Timer? _pollTimer;

  Future<void> loadPrices({bool silent = false}) async {
    if (!silent) isLoading = true;
    notifyListeners();
    try {
      prices = await _priceService.getAllPrices();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConstants.priceRefreshInterval, (_) {
      loadPrices(silent: true);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
