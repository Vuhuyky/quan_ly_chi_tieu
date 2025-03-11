import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                'Xin chào Long Dang!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Thu nhập',
                      '\$5000',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceCard(
                      'Khoản chi',
                      '\$1200',
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Tần suất chi tiêu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TODO: Add spending chart here
              const SizedBox(height: 20),
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TODO: Add recent transactions list
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 