plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mymusicplayer_new"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8  // ← Changed from VERSION_11 to VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8  // ← Changed from VERSION_11 to VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"  // ← Changed from VERSION_11 to "1.8"
    }

    defaultConfig {
        applicationId = "com.example.mymusicplayer_new"

        minSdkVersion(24)        // ← Changed from 23 to 24 (removes warning)
        targetSdkVersion(36)
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Flutter plugin configuration
flutter {
    source = "../.."
}