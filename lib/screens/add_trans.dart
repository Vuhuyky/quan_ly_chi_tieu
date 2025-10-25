import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import 'dart:async';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final List<String> expenseCategories = [
    'Ăn uống',
    'Di chuyển',
    'Giải trí',
    'Mua sắm',
    'Học tập',
    'Y tế',
    'Thể thao',
    'Nhà cửa',
    'Du lịch',
    'Khác',
  ];

  final List<String> incomeCategories = [
    'Lương',
    'Thưởng',
    'Đầu tư',
    'Quà tặng',
    'Khác',
  ];

  final _formKey = GlobalKey<FormState>();

  String _transactionType = 'expense'; // 'expense' hoặc 'income'
  String _category = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController incomeAmountController = TextEditingController();
  final TextEditingController expenseDescController = TextEditingController();
  final TextEditingController incomeDescController = TextEditingController();
  final TextEditingController customCategoryController =
      TextEditingController();

  @override
  void dispose() {
    expenseAmountController.dispose();
    incomeAmountController.dispose();
    expenseDescController.dispose();
    incomeDescController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<bool> _canAffordExpense(double expenseAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: user.uid)
            .where('year', isEqualTo: _selectedDate.year)
            .where('month', isEqualTo: _selectedDate.month)
            .get();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final type = (data['type'] ?? 'expense').toString();
      final amt = (data['amount'] ?? 0).toDouble();
      if (type == 'income') {
        totalIncome += amt;
      } else {
        totalExpense += amt;
      }
    }

    return (totalExpense + expenseAmount) <= totalIncome;
  }

  Future<void> _submitTransaction() async {
    if (_isLoading) return;

    final amountController =
        _transactionType == 'expense'
            ? expenseAmountController
            : incomeAmountController;
    final descController =
        _transactionType == 'expense'
            ? expenseDescController
            : incomeDescController;

    final double? enteredAmount = double.tryParse(amountController.text.trim());
    final String enteredDesc = descController.text.trim();

    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số tiền hợp lệ!")),
      );
      return;
    }

    // Lấy danh mục phù hợp
    final String categoryEffective =
        _category == 'Khác'
            ? customCategoryController.text.trim().isEmpty
                ? 'Khác'
                : customCategoryController.text.trim()
            : _category;

    final normalizedType = _transactionType.trim().toLowerCase();

    if (normalizedType == 'expense') {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng đăng nhập trước khi thêm giao dịch."),
          ),
        );
        return;
      }

      bool canAfford = await _canAffordExpense(enteredAmount);
      if (!canAfford) {
        final bool confirm =
            await showDialog<bool>(
              context: context,
              builder:
                  (c) => AlertDialog(
                    title: const Text("Xác nhận"),
                    content: const Text(
                      "Tổng chi sau khi thêm sẽ lớn hơn tổng thu nhập trong tháng. Bạn có muốn tiếp tục lưu?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text("Huỷ"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text("Tiếp tục"),
                      ),
                    ],
                  ),
            ) ??
            false;

        if (!confirm) return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await TransactionService.addTransaction(
        type: normalizedType,
        amount: enteredAmount,
        category: categoryEffective,
        date: _selectedDate,
        description: enteredDesc,
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          debugPrint("⚠️ Ghi giao dịch lâu hơn 12s, nhưng vẫn đang xử lý...");
          return;
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      //  Hiển thị thông báo lưu thành công (SnackBar không bị mất)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Giao dịch đã được thêm thành công!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      debugPrint(" Lỗi khi thêm giao dịch: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm giao dịch: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountController =
        _transactionType == 'expense'
            ? expenseAmountController
            : incomeAmountController;
    final descController =
        _transactionType == 'expense'
            ? expenseDescController
            : incomeDescController;

    final categoryList =
        _transactionType == 'expense' ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: AppBar(title: const Text("Thêm giao dịch")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Loại giao dịch",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Khoản chi"),
                        selected: _transactionType == 'expense',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _transactionType = 'expense';
                              _category = expenseCategories.first;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Thu nhập"),
                        selected: _transactionType == 'income',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _transactionType = 'income';
                              _category = incomeCategories.first;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: "Số tiền",
                    hintText: "Nhập số tiền",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // Danh mục cho cả Thu nhập và Khoản chi
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: "Danh mục",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      categoryList
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value ?? '';
                      if (_category != 'Khác') {
                        customCategoryController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),

                if (_category == 'Khác')
                  TextField(
                    controller: customCategoryController,
                    decoration: InputDecoration(
                      labelText: "Nhập danh mục tùy chỉnh",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Ngày: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text("Chọn ngày"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Mô tả",
                    hintText: "Nhập mô tả giao dịch",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _submitTransaction,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Lưu giao dịch"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
