# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Flutter wrappers
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Retrofit and OkHttp - useful if you add native HTTP networking
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Keep model classes for JSON parsing
-keep class com.example.eshop.models.** { *; }

# Keep custom Application classes
-keep public class * extends android.app.Application

# Prevent R8 from stripping interface information from TypeAdapter, TypeAdapterFactory
# For Gson, if you're using it in native Android
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# For Firebase (if you add it later)
-keep class com.google.firebase.** { *; }

# Keep payment processing libraries intact (common for e-commerce)
-keep class com.stripe.** { *; }
-keep class com.paypal.** { *; }

# Don't obfuscate model classes for shared preferences
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}