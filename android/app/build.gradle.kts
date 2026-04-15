plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nutech_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Updated to resolve the deprecation warning
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nutech_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // KOTLIN DSL SYNTAX FOR MINIFICATION:
            isMinifyEnabled = true 
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

// After Flutter copies the APK to outputs/flutter-apk, rename to a stable filename.
val renameReleaseApkToNutech by tasks.registering {
    group = "build"
    description = "Copy app-release.apk to nutech-app.apk (Flutter still requires app-release.apk)"
    doLast {
        val dir = layout.buildDirectory.get().asFile.resolve("outputs/flutter-apk")
        val from = dir.resolve("app-release.apk")
        val to = dir.resolve("nutech-app.apk")
        if (from.exists()) {
            // Keep app-release.apk — Flutter tooling expects it after the build.
            from.copyTo(to, overwrite = true)
        }
    }
}

// assembleRelease is created after the Android plugin configures variants.
afterEvaluate {
    tasks.named("assembleRelease").configure {
        finalizedBy(renameReleaseApkToNutech)
    }
}