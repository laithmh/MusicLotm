# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AudioService
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

# Audify (Visualizer native JNI)
-keep class com.audify.** { *; }
-keep class * implements com.audify.** { *; }

# Hive & Type Adapters
-keep class io.hive.** { *; }
-keep class * extends io.hive.TypeAdapter { *; }
-keep class * implements io.hive.TypeAdapter { *; }
-keepclassmembers class * {
    @com.hive.HiveType *;
    @com.hive.HiveField *;
}

# Keep our models
-keep class com.laithmh.musiclotm.core.model.** { *; }

# AndroidX Media & Multidex
-keep class androidx.media.** { *; }
-keep class androidx.multidex.** { *; }

# Flutter Deferred Components & Play Core (R8 suppressions)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
