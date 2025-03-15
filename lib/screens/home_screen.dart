import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quan_ly_chi_tieu/screens/transactions_screen.dart';

/// Model tạm cho Transaction (chỉ để xử lý logic)
class SimpleTransaction {
  final String type; // 'income' hoặc 'expense'
  final double amount;
  final DateTime date;
  final String description;
  SimpleTransaction(this.type, this.amount, this.date, this.description);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tổng thu nhập và chi tiêu
  double _totalIncome = 0;
  double _totalExpense = 0;
  String _userName = "Người dùng";
  bool _isLoading = false;

  // Dữ liệu biểu đồ line (6 tháng gần nhất)
  List<FlSpot> _lineSpots = [];
  double _maxY = 0; // max trên trục Y

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  /// Lấy dữ liệu từ Firestore:
  /// 1) Tính tổng thu nhập và chi tiêu
  /// 2) Tính dữ liệu 6 tháng gần nhất (chỉ expense) cho biểu đồ line
  /// 3) Lấy tên user
  Future<void> _fetchHomeData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    // Tên hiển thị (nếu null thì dùng email)
    _userName = user.displayName ?? user.email ?? "Người dùng";

    // Lấy tất cả giao dịch của user
    // Không orderBy => tránh lỗi index
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection("transactions")
            .where("userId", isEqualTo: user.uid)
            .get();

    double income = 0;
    double expense = 0;
    final List<SimpleTransaction> allTx = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final type = data['type'] ?? 'expense';
      final amount = (data['amount'] ?? 0).toDouble();
      final ts = data['date'] as Timestamp?;
      final date = ts?.toDate() ?? DateTime.now();
      final desc = data['description'] ?? '';

      if (type == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
      allTx.add(SimpleTransaction(type, amount, date, desc));
    }

    _totalIncome = income;
    _totalExpense = expense;

    // Tính dữ liệu 6 tháng gần nhất (expense) cho line chart
    final now = DateTime.now();
    final Map<String, double> monthlyExpense = {};
    // Tạo key cho 6 tháng
    for (int i = 5; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final key = "${dt.year}-${dt.month}";
      monthlyExpense[key] = 0;
    }
    // Gộp expense
    for (var tx in allTx) {
      if (tx.type == 'expense') {
        final key = "${tx.date.year}-${tx.date.month}";
        if (monthlyExpense.containsKey(key)) {
          monthlyExpense[key] = monthlyExpense[key]! + tx.amount;
        }
      }
    }

    // Tạo spots (x: 0..5)
    final List<FlSpot> spots = [];
    int index = 0;
    for (int i = 5; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final key = "${dt.year}-${dt.month}";
      final val = monthlyExpense[key] ?? 0;
      spots.add(FlSpot(index.toDouble(), val));
      index++;
    }
    double maxY = 0;
    for (var s in spots) {
      if (s.y > maxY) maxY = s.y;
    }

    setState(() {
      _lineSpots = spots;
      _maxY = maxY;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: avatar + tên user
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Welcome,'
                            '$_userName!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Thu nhập + Chi tiêu
                      Row(
                        children: [
                          Expanded(
                            child: _buildBalanceCard(
                              'Thu nhập',
                              '\$${_totalIncome.toStringAsFixed(0)}',
                              Colors.green,
                              Icons.arrow_downward,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBalanceCard(
                              'Khoản chi',
                              '\$${_totalExpense.toStringAsFixed(0)}',
                              Colors.red,
                              Icons.arrow_upward,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Biểu đồ line gradient
                      const Text(
                        'Tần suất chi tiêu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            _lineSpots.isEmpty
                                ? const Center(
                                  child: Text("Chưa có dữ liệu chi tiêu"),
                                )
                                : _buildGradientLineChart(),
                      ),
                      const SizedBox(height: 24),

                      // Recent Transaction (chỉ hiển thị khoản chi)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transaction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Điều hướng sang TransactionScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const TransactionScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecentExpense(),
                    ],
                  ),
                ),
      ),
    );
  }

  /// Thẻ hiển thị thu nhập / khoản chi
  Widget _buildBalanceCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Biểu đồ line gradient
  Widget _buildGradientLineChart() {
    // X = 0..5, Y = 0.._maxY
    final gradientColors = [Colors.purple, Colors.purple.withOpacity(0.0)];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: _maxY * 1.2,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt(); // 0..5
                return Text(
                  "M${index + 1}",
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _lineSpots,
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            // Chấm tròn
            dotData: FlDotData(show: true),
            // Gradient bên dưới line
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Transaction: chỉ hiển thị khoản chi (expense)
  Widget _buildRecentExpense() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Text("Chưa đăng nhập");

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("transactions")
              .where("userId", isEqualTo: user.uid)
              // .orderBy("date", descending: true) // nếu muốn, tạo index
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Lỗi: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Không có khoản chi gần đây");
        }
        final docs = snapshot.data!.docs;
        // parse
        final allTx =
            docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'expense';
              final amount = (data['amount'] ?? 0).toDouble();
              final desc = data['description'] ?? '';
              final ts = data['date'] as Timestamp?;
              final dt = ts?.toDate() ?? DateTime.now();
              return SimpleTransaction(type, amount, dt, desc);
            }).toList();

        // Lọc chỉ expense
        final expenseTx = allTx.where((tx) => tx.type == 'expense').toList();
        // Sắp xếp cục bộ giảm dần
        expenseTx.sort((a, b) => b.date.compareTo(a.date));
        // Lấy 3 giao dịch
        final recent = expenseTx.take(3).toList();

        if (recent.isEmpty) {
          return const Text("Không có khoản chi gần đây");
        }

        return Column(
          children:
              recent.map((tx) {
                final color = Colors.red;
                final sign = "-";
                final timeString = DateFormat.jm().format(tx.date);
                return _buildTransactionItem(
                  title: "Chi tiêu",
                  subtitle:
                      tx.description.isNotEmpty
                          ? tx.description
                          : "Không có mô tả",
                  time: timeString,
                  amount: -tx.amount, // expense => âm
                  color: color,
                  icon: Icons.shopping_bag,
                );
              }).toList(),
        );
      },
    );
  }

  /// Widget 1 item giao dịch
  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String time,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon + background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          // Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          // Amount + time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount < 0
                    ? "-\$${amount.abs().toStringAsFixed(0)}"
                    : "+\$${amount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amount < 0 ? Colors.red : Colors.green,
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
