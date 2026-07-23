# AI Forex Signals — Flutter Android App

Native Android client (built with Flutter, no Python/MT5 required on-device) for the
FastAPI backend from Step 1. Talks to the backend over HTTPS/JWT only — it never touches
Twelve Data or any secret API key directly.

## What's included

```
forex_signals_app/
├── lib/
│   ├── main.dart                     # entry point, Firebase init, providers, routing
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── theme/app_theme.dart      # dark theme
│   │   ├── network/api_client.dart   # Dio client, JWT interceptor, auto token refresh
│   │   ├── network/api_exception.dart
│   │   ├── storage/secure_storage.dart
│   │   └── utils/formatters.dart
│   ├── models/                       # UserModel, SignalModel, PriceModel, NotificationModel
│   ├── services/                     # auth, signals, prices, users, notifications, FCM
│   ├── providers/                    # AuthProvider, SignalProvider, PriceProvider, SettingsProvider
│   ├── screens/
│   │   ├── splash/
│   │   ├── auth/                     # login, register
│   │   ├── dashboard/                # bottom-nav shell + home tab (live prices + signals)
│   │   ├── signals/                  # history (search/filter) + detail
│   │   ├── favorites/                # manage & view favorite pairs
│   │   ├── profile/
│   │   └── settings/
│   └── widgets/                      # SignalCard, PriceTickerItem, loading/error states
├── android/app/src/main/AndroidManifest.xml
├── android/app/build.gradle          # Firebase + build config notes (merge into generated file)
├── android/build.gradle              # Firebase plugin classpath (merge into generated file)
└── pubspec.yaml
```

## 1. Prerequisites

- Flutter SDK 3.22+ (`flutter --version`)
- Android Studio or the Android SDK command-line tools (API 34)
- A Firebase project (free tier is enough) for push notifications
- The backend from Step 1 already deployed and reachable over HTTPS

## 2. Scaffold the native Android project

This repo ships only the Dart source and the Android config files that differ from the
default template (to keep the deliverable focused). Generate the rest once with the
Flutter CLI, then drop these files in:

```bash
flutter create --org com.aiforexsignals --project-name forex_signals_app .
```

Then:
1. Copy `lib/` and `pubspec.yaml` from this deliverable into the generated project (overwrite).
2. Merge `android/app/src/main/AndroidManifest.xml` into the generated one (it's provided
   here as a complete file — you can overwrite the generated one directly).
3. Merge the two `build.gradle` snippets into the generated `android/build.gradle` and
   `android/app/build.gradle` — add the marked lines, don't replace the whole file.

```bash
flutter pub get
```

## 3. Firebase setup (push notifications)

1. Go to the [Firebase console](https://console.firebase.google.com) → create a project.
2. Add an Android app with package name `com.aiforexsignals.app` (or whatever you set
   above via `--org`).
3. Download `google-services.json` and place it at `android/app/google-services.json`.
4. On the **backend**, generate a service-account key (Project settings → Service accounts
   → Generate new private key) and point `FIREBASE_CREDENTIALS_PATH` at it — this is what
   lets the backend push notifications, per Step 1's README.
5. That's it on the app side — `FcmService` in `lib/services/fcm_service.dart` handles
   permission requests, topic subscription (`signals` topic — matches the backend's
   `broadcast_new_signal`), foreground notification display, and tap-to-open-signal
   navigation automatically.

## 4. Point the app at your backend

The backend URL is injected at build time (never hardcoded, never bundled with secrets):

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend-domain.com
```

For a release build, use the same flag (see step 6).

## 5. Run in development

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-backend-domain.com
```

Login with the admin bootstrap account from Step 1's `.env` (`ADMIN_EMAIL` /
`ADMIN_PASSWORD`) or register a new user from the app.

## 6. Build a release APK

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-backend-domain.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

For the Play Store, build an App Bundle instead and set up proper release signing
(replace `signingConfig signingConfigs.debug` in `android/app/build.gradle` with your own
keystore config first):

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-backend-domain.com
```

## 7. What's implemented

- **Auth**: register/login/JWT session persisted in `flutter_secure_storage`, automatic
  access-token refresh via `ApiClient`'s Dio interceptor, forced logout if the refresh
  token itself expires.
- **Dashboard**: live price ticker (polls `/api/v1/prices` every 15s) + latest AI signals
  (polls `/api/v1/signals/latest` every 60s), pull-to-refresh.
- **Signal detail**: entry/SL/TP1/TP2, RR ratio, AI confidence gauge, explanation, and the
  list of confluences (indicators + SMC) that fired.
- **History**: search by currency pair, filter by Buy/Sell.
- **Favorites**: pick from the 10 supported pairs; synced to the backend via
  `PATCH /users/me`; shows only signals for favorited pairs.
- **Push notifications**: FCM topic subscription, foreground local-notification display,
  tap-to-open the relevant signal from a cold start, background, or foreground state.
- **Profile / Settings**: edit name, view favorites, delete (deactivate) account, toggle
  notification preference, log out.
- **Error handling**: every network call surfaces a human-readable `ApiException`; retry
  buttons on failed loads; shimmer skeletons while loading; empty states.

All data is live from the backend — there is no mock/placeholder data anywhere in the
provider or service layer.

## 8. Known follow-ups for a Play Store launch

- Wire a real release keystore (`android/key.properties` + `signingConfigs.release`).
- Add app icons/splash branding (`flutter_launcher_icons` / `flutter_native_splash`).
- Add crash reporting (Firebase Crashlytics) — not included here to keep the dependency
  surface minimal, but it's a natural next addition once you're stabilizing for release.
