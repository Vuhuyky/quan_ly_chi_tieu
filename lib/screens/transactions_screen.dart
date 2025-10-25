import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/models/transaction.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final List<String> categories = [
    'Tất cả',
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

  String selectedCategory = 'Tất cả';

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return FontAwesomeIcons.utensils;
      case 'Di chuyển':
        return FontAwesomeIcons.bus;
      case 'Giải trí':
        return FontAwesomeIcons.film;
      case 'Mua sắm':
        return FontAwesomeIcons.shoppingBag;
      case 'Học tập':
        return FontAwesomeIcons.bookOpen;
      case 'Y tế':
        return FontAwesomeIcons.briefcaseMedical;
      case 'Thể thao':
        return FontAwesomeIcons.football;
      case 'Nhà cửa':
        return FontAwesomeIcons.house;
      case 'Du lịch':
        return FontAwesomeIcons.plane;
      case 'Khác':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Bạn chưa đăng nhập")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Giao dịch")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bộ lọc tháng và năm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                    }
                  },
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(
                        DateFormat.MMMM().format(DateTime(2000, month)),
                      ),
                    );
                  }),
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
                    }
                  },
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - 2 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bộ lọc danh mục
            DropdownButton<String>(
              value: selectedCategory,
              items:
                  categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // Danh sách giao dịch
            // ...existing code...
            // Danh sách giao dịch
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("transactions")
                        .where("userId", isEqualTo: user!.uid)
                        .where("year", isEqualTo: _selectedYear)
                        .where("month", isEqualTo: _selectedMonth)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text("Không có giao dịch"));
                  }

                  // Chuyển docs -> model và sort giảm dần
                  final allTransactions =
                      docs
                          .map((doc) => TransactionModel.fromFirestore(doc))
                          .toList()
                        ..sort((a, b) => b.date.compareTo(a.date));

                  // Phân loại (chuẩn hoá type)
                  final expenseList =
                      allTransactions
                          .where(
                            (t) =>
                                t.type.toString().trim().toLowerCase() ==
                                'expense',
                          )
                          .toList();
                  final incomeList =
                      allTransactions
                          .where(
                            (t) =>
                                t.type.toString().trim().toLowerCase() ==
                                'income',
                          )
                          .toList();

                  // Lọc theo danh mục
                  final filteredExpenseList =
                      selectedCategory == 'Tất cả'
                          ? expenseList
                          : expenseList
                              .where((t) => t.category == selectedCategory)
                              .toList();
                  final filteredIncomeList =
                      selectedCategory == 'Tất cả'
                          ? incomeList
                          : incomeList
                              .where((t) => t.category == selectedCategory)
                              .toList();

                  // Tính tổng
                  final totalExpense = filteredExpenseList.fold<double>(
                    0.0,
                    (sum, t) => sum + t.amount,
                  );
                  final totalIncome = filteredIncomeList.fold<double>(
                    0.0,
                    (sum, t) => sum + t.amount,
                  );

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Xem báo cáo tài chính của bạn",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tổng chi: -\$${totalExpense.toStringAsFixed(0)}    Tổng thu: +\$${totalIncome.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Khoản Chi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredExpenseList.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionItem(
                              filteredExpenseList[index],
                              isExpense: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Thu nhập",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredIncomeList.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionItem(
                              filteredIncomeList[index],
                              isExpense: false,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel t, {required bool isExpense}) {
    final iconBgColor = isExpense ? Colors.red[50] : Colors.green[50];
    final iconColor = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? "-" : "+";
    final amountColor = isExpense ? Colors.red : Colors.green;

    final timeString = DateFormat.jm().format(t.date);
    final subtitle =
        t.description.isNotEmpty
            ? t.description
            : DateFormat('dd/MM').format(t.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getCategoryIcon(t.category),
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$sign\$${t.amount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              Text(
                timeString,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
