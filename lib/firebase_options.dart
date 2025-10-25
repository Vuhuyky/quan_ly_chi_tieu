// File: lib/firebase_options.dart
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Cấu hình Firebase cho project "btl-pttkpm"
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase chưa được cấu hình cho Linux.');
      default:
        throw UnsupportedError('Firebase chưa hỗ trợ cho nền tảng này.');
    }
  }

  ///  Web App (nếu bạn có tạo trong Firebase Console)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCX8RUoSM4tNWsKMhgM3wZOCRNC0CRS0jU',
    appId: '1:317508043698:web:08ff55105c2b310d079aab',
    messagingSenderId: '317508043698',
    projectId: 'btl-pttkpm',
    authDomain: 'btl-pttkpm.firebaseapp.com',
    storageBucket: 'btl-pttkpm.firebasestorage.app',
    measurementId: 'G-DESSBB16V2',
  );

  ///  Android App
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCX8RUoSM4tNWsKMhgM3wZOCRNC0CRS0jU',
    appId: '1:317508043698:android:9a15c98293a47b34079aab',
    messagingSenderId: '317508043698',
    projectId: 'btl-pttkpm',
    storageBucket: 'btl-pttkpm.firebasestorage.app',
  );

  ///  iOS App (chưa cấu hình nên dùng placeholder)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FAKE-IOS-API-KEY',
    appId: 'FAKE-IOS-APP-ID',
    messagingSenderId: '317508043698',
    projectId: 'btl-pttkpm',
    storageBucket: 'btl-pttkpm.firebasestorage.app',
  );

  /// 🍏 macOS dùng chung cấu hình với iOS (placeholder)
  static const FirebaseOptions macos = ios;

  /// 💻 Windows App (placeholder)
  static const FirebaseOptions windows = web;
}
