plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // 🔹 Đặt ở cuối, sau kotlin-android
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.quan_ly_chi_tieu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.quan_ly_chi_tieu"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 🔹 Import Firebase BoM (quản lý version đồng bộ)
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // 🔹 Thêm Firebase Analytics (tự động track event)
    implementation("com.google.firebase:firebase-analytics")

    // 🔹 (Tùy chọn) Firebase Auth, Firestore, Storage...
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}

flutter {
    source = "../.."
}
