import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'auth/auth_wrapper.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔗 Gắn Realtime Database URL (rất quan trọng!)
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://btl-pttkpm-default-rtdb.asia-southeast1.firebasedatabase.app/',
  );

  // 🧪 Test ghi dữ liệu lên Firebase để kiểm tra kết nối
  await database.ref('test_connection').set({
    'status': 'connected',
    'timestamp': DateTime.now().toIso8601String(),
  });

  print('✅ Firebase Realtime Database connected successfully!');

  // 🧩 Chạy ứng dụng
  runApp(
    DevicePreview(
      enabled: !const bool.fromEnvironment('dart.vm.product'),
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Quản Lý Chi Tiêu',
          debugShowCheckedModeBanner: false,

          // ⚙️ Cho phép DevicePreview mô phỏng thiết bị
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,

          // 🎨 Giao diện sáng và tối
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          // 🏠 Trang đầu tiên
          home: const AuthWrapper(),
        );
      },
    );
  }
}
