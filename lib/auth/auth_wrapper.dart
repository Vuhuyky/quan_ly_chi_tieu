import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/auth/email_verify.dart';
import '../screens/main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Hiển thị vòng tròn loading khi chờ
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Nếu chưa đăng nhập, chuyển sang LoginScreen
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }
        // Đã đăng nhập, kiểm tra email đã xác nhận hay chưa
        final user = snapshot.data!;
        if (!user.emailVerified) {
          return const EmailNotVerifiedScreen();
        }
        return const MainScreen();
      },
    );
  }
}
