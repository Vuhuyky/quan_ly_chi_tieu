import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/profile_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex >= 3 ? _selectedIndex - 1 : _selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Hiển thị dialog thêm giao dịch
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            if (index == 2) {
              // TODO: Hiển thị dialog thêm giao dịch
            } else {
              _selectedIndex = index;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            activeIcon: Icon(Icons.add_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Ngân sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
