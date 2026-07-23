import 'package:dio/dio.dart';
import 'package:forex_signals_app/core/constants/app_constants.dart';
import 'package:forex_signals_app/core/network/api_exception.dart';
import 'package:forex_signals_app/core/storage/secure_storage.dart';

/// Central HTTP client for all backend calls. Handles:
///  - attaching the JWT access token to every request
///  - transparently refreshing an expired access token once, then retrying
///  - normalizing every failure into an [ApiException] the UI can render
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiV1,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.instance.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final cloned = await _retry(error.requestOptions);
            return handler.resolve(cloned);
          } else {
            onSessionExpired?.call();
          }
        }
        handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  bool _isRefreshing = false;

  /// Registered by AuthProvider so the client can force a logout when the
  /// refresh token itself is no longer valid.
  void Function()? onSessionExpired;

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final refreshToken = await SecureStorage.instance.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: AppConstants.apiV1)).post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      await SecureStorage.instance.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
      return true;
    } catch (_) {
      await SecureStorage.instance.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await SecureStorage.instance.getAccessToken();
    final options = Options(method: requestOptions.method, headers: {
      ...requestOptions.headers,
      'Authorization': 'Bearer $token',
    });
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  ApiException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiException('Cannot reach the server. Check your internet connection.');
    }
    final status = e.response?.statusCode;
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    return ApiException(
      detail?.toString() ?? e.message ?? 'Something went wrong. Please try again.',
      statusCode: status,
    );
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return res.data is Map<String, dynamic> ? res.data : {'data': res.data};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return res.data as List<dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final res = await _dio.post(path, data: data);
      return res.data is Map<String, dynamic> ? res.data : {'data': res.data};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final res = await _dio.patch(path, data: data);
      return res.data is Map<String, dynamic> ? res.data : {'data': res.data};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }
}
