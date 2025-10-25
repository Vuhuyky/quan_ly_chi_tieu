import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:open_filex/open_filex.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({Key? key}) : super(key: key);

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _exporting = false;

  Future<void> _exportData() async {
    setState(() => _exporting = true);

    try {
      // 🔹 Yêu cầu quyền ghi file (Android 13+ cần)
      if (await Permission.storage.request().isDenied) {
        throw Exception("Không có quyền ghi file");
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Bạn chưa đăng nhập");

      // 🔹 Lấy dữ liệu từ Firestore
      final snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: user.uid)
              .orderBy('date', descending: true)
              .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không có dữ liệu để xuất")),
        );
        setState(() => _exporting = false);
        return;
      }

      // 🔹 Chuyển dữ liệu sang CSV
      List<List<dynamic>> rows = [
        ["Loại", "Danh mục", "Số tiền", "Ngày", "Mô tả"],
      ];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        rows.add([
          data['type'],
          data['category'],
          data['amount'],
          (data['date'] as Timestamp).toDate().toString(),
          data['description'] ?? "",
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      // 🔹 Lưu file vào thư mục Download
      final directory = await getDownloadsDirectory();
      final path =
          "${directory!.path}/chi_tieu_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xuất dữ liệu thành công: $path")),
      );

      // 🔹 Mở file sau khi lưu
      await OpenFilex.open(path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi xuất dữ liệu: $e")));
    } finally {
      setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xuất dữ liệu")),
      body: Center(
        child:
            _exporting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Xuất dữ liệu CSV"),
                  onPressed: _exportData,
                ),
      ),
    );
  }
}
