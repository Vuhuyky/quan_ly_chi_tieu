import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tai Khoan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuItem(
                icon: Icons.person,
                title: 'Về của tôi',
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Cài đặt',
              ),
              _buildMenuItem(
                icon: Icons.download,
                title: 'Xuất dữ liệu',
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.purple,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }
} 