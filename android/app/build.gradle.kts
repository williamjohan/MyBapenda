import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget 

plugins {
    id("com.android.application")
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.go.surabaya.mybapenda"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Mengabaikan error linting agar tidak menggagalkan proses build release (CI/CD)
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
        applicationId = "id.go.surabaya.mybapenda"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion 
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject Google Maps API Key dari .env root ke dalam AndroidManifest
        val envProps = Properties()
        val envFile = rootProject.file("../.env")
        if (envFile.exists()) {
            envFile.inputStream().use { envProps.load(it) }
        }
        manifestPlaceholders["googleMapsApiKey"] = 
            envProps.getProperty("GOOGLE_MAPS_API_KEY", "").trim('"', ' ')
    }


    val keystoreProperties = Properties()
    val keystorePropertiesFile = file("key.properties")

    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "key.properties tidak ditemukan di android/app/"
        )
    }

    keystorePropertiesFile.inputStream().use {
        keystoreProperties.load(it)
    }

    val debugKeystoreFile = file(
        keystoreProperties.getProperty("storeFile")
            ?: "upload-keystore.jks"
    )

    if (!debugKeystoreFile.exists()) {
        throw GradleException(
            "Debug keystore tidak ditemukan: ${debugKeystoreFile.absolutePath}"
        )
    }

    // Load Play Store signing properties
    val playstoreProperties = Properties()
    val playstorePropertiesFile = file("playstore.properties")

    if (!playstorePropertiesFile.exists()) {
        throw GradleException(
            "playstore.properties tidak ditemukan di android/app/"
        )
    }

    playstorePropertiesFile.inputStream().use {
        playstoreProperties.load(it)
    }

    val playstoreKeystoreFile = file(
        playstoreProperties.getProperty("storeFile")
            ?: "dinkominfo.jks"
    )

    if (!playstoreKeystoreFile.exists()) {
        throw GradleException(
            "Play Store keystore tidak ditemukan: ${playstoreKeystoreFile.absolutePath}"
        )
    }

    signingConfigs {
        create("debugCustom") {
            storeFile = debugKeystoreFile
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            
        }

        create("release") {
            storeFile = playstoreKeystoreFile
            storePassword = playstoreProperties.getProperty("storePassword")
            keyAlias = playstoreProperties.getProperty("keyAlias")
            keyPassword = playstoreProperties.getProperty("keyPassword")

            enableV1Signing = true
            enableV2Signing = true
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debugCustom")
        }
        release {
            // Fallback otomatis ke debug signing jika file keystore tidak ditemukan
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            // Mengecilkan ukuran APK/AAB dan menyembunyikan source code (Obfuscation)
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

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
    
    // Wajib ditambahkan jika isCoreLibraryDesugaringEnabled = true (Support Java 17 API di Android lama)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}