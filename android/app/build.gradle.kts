import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")

    // FlutterFire Configuration
    id("com.google.gms.google-services")

    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

// ============================================================
// RELEASE SIGNING
// Reads android/key.properties
// ============================================================

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

android {
    namespace = "com.example.sakhi_pravas"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.sakhi_pravas"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ========================================================
    // RELEASE SIGNING CONFIGURATION
    // ========================================================

    signingConfigs {
        create("release") {

            val storePasswordValue =
                keystoreProperties.getProperty("storePassword")

            val keyPasswordValue =
                keystoreProperties.getProperty("keyPassword")

            val keyAliasValue =
                keystoreProperties.getProperty("keyAlias")

            val storeFileValue =
                keystoreProperties.getProperty("storeFile")

            require(!storePasswordValue.isNullOrBlank()) {
                "storePassword is missing from android/key.properties"
            }

            require(!keyPasswordValue.isNullOrBlank()) {
                "keyPassword is missing from android/key.properties"
            }

            require(!keyAliasValue.isNullOrBlank()) {
                "keyAlias is missing from android/key.properties"
            }

            require(!storeFileValue.isNullOrBlank()) {
                "storeFile is missing from android/key.properties"
            }

            storePassword = storePasswordValue
            keyPassword = keyPasswordValue
            keyAlias = keyAliasValue
            storeFile = file(storeFileValue)
        }
    }

    // ========================================================
    // RELEASE BUILD
    // ========================================================

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}