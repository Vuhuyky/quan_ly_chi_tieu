import 'package:flutter/material.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về của tôi'),
        backgroundColor: Colors.purple.shade400,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Ứng dụng quản lý chi tiêu cá nhân.\n'
          'Phiên bản: 1.0.0\n'
          'Nhóm phát triển: Ky Huy & Team\n\n'
          'Ứng dụng giúp người dùng ghi chép, thống kê, và xuất báo cáo chi tiêu hằng ngày.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
