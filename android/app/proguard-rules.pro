# Keep OkHttp3 classes that ucrop depends on
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# If you still get errors, add this for ucrop specifically
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**