class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  bool get isAuthError => statusCode == 401;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}
