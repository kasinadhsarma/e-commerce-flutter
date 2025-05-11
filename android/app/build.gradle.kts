plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ecommerce_app"
    
    // Flutter sets compileSdkVersion, but we'll use a more explicit approach
    compileSdk = 34
    ndkVersion = "26.1.10909125"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.ecommerce_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex for large apps with many methods
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Enables code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Enables resource shrinking
            isShrinkResources = true
            
            signingConfig = signingConfigs.getByName("debug")
        }
        
        debug {
            // Application ID suffix for debug builds
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }
    
    // Enable view binding
    buildFeatures {
        viewBinding = true
    }
    
    // Configure product flavors if needed (e.g., free vs premium versions)
    flavorDimensions.add("version")
    productFlavors {
        create("free") {
            dimension = "version"
            applicationIdSuffix = ".free"
            versionNameSuffix = "-free"
        }
        
        create("paid") {
            dimension = "version"
            applicationIdSuffix = ".paid"
            versionNameSuffix = "-paid"
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}

flutter {
    source = "../.."
}
