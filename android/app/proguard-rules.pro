# Flutter & Platform Channels
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter Engine Entrypoints
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }
-keep class * extends io.flutter.embedding.android.FlutterActivity { *; }
-keep class * extends io.flutter.embedding.android.FlutterFragmentActivity { *; }

# Google Play Services & Firebase Core
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firebase Auth & Credentials
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepclassmembers class * {
    @com.google.firebase.auth.** *;
}
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.auth.**

# Cloud Firestore
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.firebase.firestore.** *;
}
-keep class com.google.firebase.firestore.** { *; }
-dontwarn com.google.firebase.firestore.**

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }
-dontwarn com.google.firebase.storage.**

# Syncfusion PDF & Printing
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**
-keep class net.nfet.flutter.printing.** { *; }
-dontwarn net.nfet.flutter.printing.**

# Audioplayers & Media
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Lottie Animations
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# Protobuf & gRPC (Used by Firestore SDK)
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Suppress Google Play Core deferred components / split install warnings
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep Flutter PlayStore split classes
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class com.google.android.play.core.** { *; }

# General Flutter & Plugin keep rules
-dontwarn io.flutter.plugins.**
-dontwarn com.google.firebase.**
-dontwarn io.grpc.**