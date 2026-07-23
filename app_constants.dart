class AppConstants {
  AppConstants._();

  // Point this at your deployed FastAPI backend from Step 1.
  // Never hardcode secrets here - the backend alone holds TWELVE_DATA_API_KEY.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-backend-domain.com',
  );

  static const String apiV1 = '$baseUrl/api/v1';

  // Secure storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';

  // Shared preferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  static const List<String> supportedPairs = [
    'EUR/USD',
    'GBP/USD',
    'USD/JPY',
    'USD/CAD',
    'AUD/USD',
    'NZD/USD',
    'EUR/JPY',
    'GBP/JPY',
    'XAU/USD',
    'BTC/USD',
  ];

  static const Duration priceRefreshInterval = Duration(seconds: 15);
  static const Duration signalRefreshInterval = Duration(seconds: 60);

  // FCM topic all devices subscribe to for broadcast signal notifications
  static const String fcmSignalsTopic = 'signals';
}
