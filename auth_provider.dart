import 'package:flutter/foundation.dart';
import 'package:forex_signals_app/core/network/api_client.dart';
import 'package:forex_signals_app/core/network/api_exception.dart';
import 'package:forex_signals_app/core/storage/secure_storage.dart';
import 'package:forex_signals_app/models/user_model.dart';
import 'package:forex_signals_app/services/auth_service.dart';
import 'package:forex_signals_app/services/fcm_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  AuthProvider() {
    ApiClient.instance.onSessionExpired = _handleSessionExpired;
  }

  Future<void> checkSession() async {
    final hasSession = await SecureStorage.instance.hasSession();
    if (!hasSession) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      currentUser = await _authService.getCurrentUser();
      status = AuthStatus.authenticated;
      await FcmService.instance.registerTokenWithBackend();
    } catch (_) {
      await SecureStorage.instance.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentUser = await _authService.login(email: email, password: password);
      status = AuthStatus.authenticated;
      await FcmService.instance.registerTokenWithBackend();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.register(email: email, password: password, fullName: fullName);
      return await login(email, password);
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    currentUser = user;
    notifyListeners();
  }

  void updateFavorites(List<String> favorites) {
    if (currentUser == null) return;
    currentUser = UserModel(
      id: currentUser!.id,
      email: currentUser!.email,
      fullName: currentUser!.fullName,
      role: currentUser!.role,
      isActive: currentUser!.isActive,
      favoritePairs: favorites,
      createdAt: currentUser!.createdAt,
    );
    notifyListeners();
  }

  void _handleSessionExpired() {
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
