import 'package:flutter/material.dart';
import '../services/budget_service.dart';

class SetBudgetScreen extends StatefulWidget {
  final String category;
  const SetBudgetScreen({super.key, required this.category});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  double _budgetAmount = 0;
  bool _isLoading = false;

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      await BudgetService.setBudget(
        category: widget.category,
        budgetAmount: _budgetAmount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ngân sách đã được cập nhật thành công")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi cập nhật ngân sách: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thiết lập ngân sách cho ${widget.category}")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Số tiền ngân sách",
                    hintText: "Nhập số tiền",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập số tiền ngân sách";
                    }
                    final num? amount = num.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return "Số tiền không hợp lệ";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _budgetAmount = double.parse(value!.trim());
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submitBudget,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Lưu ngân sách"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
