# ProGuard / R8 rules for release builds (minify + Dart --obfuscate).
# None of our plugins ship consumer rules, so the app keeps the
# method-channel entry points explicitly. Flutter engine + androidx
# FileProvider (used by share_plus) are kept unconditionally.

# --- Flutter engine ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keepclasseswithmembernames class * { native <methods>; }
-dontwarn io.flutter.**

# --- Plugins: method channels are looked up by name from Dart ---
-keep class com.baseflow.permissionhandler.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.example.image_gallery_saver_plus.** { *; }
-keep class androidx.core.content.FileProvider { *; }
-keep class androidx.lifecycle.** { *; }
-dontwarn com.baseflow.**
-dontwarn dev.fluttercommunity.**
-dontwarn com.it_nomads.**
-dontwarn com.example.image_gallery_saver_plus.**
