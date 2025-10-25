import 'package:flutter/material.dart';
import 'about_me_screen.dart';
import 'settings_screen.dart';
import 'export_data_screen.dart';
import '../auth/auth_wrapper.dart'; // Đường dẫn đến nơi xử lý đăng xuất, nếu có
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_ProfileOption> options = [
      _ProfileOption(
        icon: Icons.person,
        title: 'Về của tôi',
        color: Colors.purple.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutMeScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.settings,
        title: 'Cài đặt',
        color: Colors.purple.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.download,
        title: 'Xuất dữ liệu',
        color: Colors.purple.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExportDataScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.logout,
        title: 'Đăng xuất',
        color: Colors.red,
        onTap: () => _logout(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                "Tài Khoản",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(option.icon, color: option.color),
                        title: Text(
                          option.title,
                          style: TextStyle(
                            color:
                                option.color == Colors.red
                                    ? Colors.red
                                    : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: option.onTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  _ProfileOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
