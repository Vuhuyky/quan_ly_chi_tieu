import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = ThemeManager.themeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Chế độ tối"),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              ThemeManager.toggleTheme(value); // ⚡ Gọi cập nhật toàn app
            },
            secondary: const Icon(Icons.dark_mode),
          ),
        ],
      ),
    );
  }
}
