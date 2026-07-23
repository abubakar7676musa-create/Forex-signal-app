# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Messaging / Cloud Messaging
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Gson / JSON models used transitively by Firebase
-keepattributes Signature
-keepattributes *Annotation*

# OkHttp / Dio networking (used by the dio package under the hood)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Keep our own model classes' field names (defensive, in case of future reflection-based JSON)
-keepclassmembers class com.aiforexsignals.app.** { *; }
