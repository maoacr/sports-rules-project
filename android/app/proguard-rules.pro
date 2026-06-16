# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class com.google.firebase.** { *; }
-keep class com.google.firebase.** { *; }

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.protobuf.** { *; }

# Keep generic signatures for Gson
-keepattributes Signature
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Isar
-keep class com.isar.** { *; }
-dontwarn com.isar.**
