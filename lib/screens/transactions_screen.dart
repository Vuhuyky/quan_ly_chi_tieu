import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xem báo cáo tài chính của bạn',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      isSelected: true,
                      title: 'Khoản Chi',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFilterButton(
                      isSelected: false,
                      title: 'Thu nhập',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildTransactionItem(
                      title: 'Mua sắm',
                      amount: -120,
                      time: '10:00 AM',
                      icon: Icons.shopping_bag,
                      color: Colors.orange,
                    ),
                    _buildTransactionItem(
                      title: 'Đăng ký hàng tháng',
                      amount: -80,
                      time: '03:30 PM',
                      icon: Icons.subscriptions,
                      color: Colors.purple,
                    ),
                    _buildTransactionItem(
                      title: 'Thức ăn',
                      amount: -32,
                      time: '07:30 PM',
                      icon: Icons.restaurant,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required bool isSelected,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required double amount,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
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
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$$amount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 