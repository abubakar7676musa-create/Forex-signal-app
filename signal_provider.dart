import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:forex_signals_app/core/constants/app_constants.dart';
import 'package:forex_signals_app/core/network/api_exception.dart';
import 'package:forex_signals_app/models/signal_model.dart';
import 'package:forex_signals_app/services/signal_service.dart';

enum LoadState { initial, loading, success, error }

class SignalProvider extends ChangeNotifier {
  final SignalService _signalService = SignalService();

  List<SignalModel> latestSignals = [];
  List<SignalModel> historySignals = [];
  List<SignalModel> favoriteSignals = [];

  LoadState latestState = LoadState.initial;
  LoadState historyState = LoadState.initial;
  LoadState favoritesState = LoadState.initial;
  String? errorMessage;

  Timer? _pollTimer;

  Future<void> loadLatest({bool silent = false}) async {
    if (!silent) latestState = LoadState.loading;
    notifyListeners();
    try {
      latestSignals = await _signalService.getLatestSignals(limit: 20);
      latestState = LoadState.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      latestState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadHistory({String? pair, String? direction}) async {
    historyState = LoadState.loading;
    notifyListeners();
    try {
      historySignals = await _signalService.getSignals(pair: pair, direction: direction, limit: 100);
      historyState = LoadState.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      historyState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    favoritesState = LoadState.loading;
    notifyListeners();
    try {
      favoriteSignals = await _signalService.getFavoriteSignals();
      favoritesState = LoadState.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      favoritesState = LoadState.error;
    }
    notifyListeners();
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConstants.signalRefreshInterval, (_) {
      loadLatest(silent: true);
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
