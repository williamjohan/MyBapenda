import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget // 🚀 Tambahkan import ini

plugins {
    id("com.android.application")
    id("kotlin-android") // Atau "org.jetbrains.kotlin.android"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bapenda.cekreklame"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.bapenda.cekreklame"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🚀 BACA KEYSTORE (Tetap gunakan file() karena di Bapenda ada di folder 'app')
    val keystoreProperties = Properties()
    val keystorePropertiesFile = file("key.properties") 
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        getByName("debug") { }

        // 🚀 SAFETY NET ALA SURABAYA TAX
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file("upload-keystore.jks")
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                
                enableV1Signing = true
                enableV2Signing = true
            }
        }
    }

    buildTypes {
        release {
            // 🚀 FALLBACK ALA SURABAYA TAX
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// 🚀 SINTAKS KOTLIN TERBARU
kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-maps:18.1.0") 
    implementation("androidx.exifinterface:exifinterface:1.3.3")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}