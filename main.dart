import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/providers/auth_provider.dart';
import 'package:forex_signals_app/providers/price_provider.dart';
import 'package:forex_signals_app/providers/settings_provider.dart';
import 'package:forex_signals_app/providers/signal_provider.dart';
import 'package:forex_signals_app/screens/signals/signal_detail_screen.dart';
import 'package:forex_signals_app/screens/splash/splash_screen.dart';
import 'package:forex_signals_app/services/fcm_service.dart';
import 'package:forex_signals_app/services/signal_service.dart';

// Global navigator key so FCM notification taps can navigate from anywhere,
// including from a cold app start.
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await FcmService.instance.initialize();
  FcmService.instance.onSignalNotificationTapped = _handleSignalNotificationTap;

  runApp(const ForexSignalsApp());
}

Future<void> _handleSignalNotificationTap(Map<String, dynamic> data) async {
  final signalId = data['signal_id'];
  if (signalId == null) return;
  try {
    final signal = await SignalService().getSignalById(signalId.toString());
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => SignalDetailScreen(signal: signal)),
    );
  } catch (_) {
    // Signal may have been deleted or the user isn't authenticated yet; fail silently.
  }
}

class ForexSignalsApp extends StatelessWidget {
  const ForexSignalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SignalProvider()),
        ChangeNotifierProvider(create: (_) => PriceProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      child: MaterialApp(
        title: 'AI Forex Signals',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
