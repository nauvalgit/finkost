import 'package:flutter/material.dart';
import 'package:finkost/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:finkost/features/statistics/presentation/pages/statistics_page.dart';
import 'package:finkost/features/transactions/presentation/pages/add_transaction_page.dart'; 


class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  
  final List<Widget> _pages = [
    const DashboardPage(),
    const AddTransactionPage(), 
    const StatisticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        backgroundColor: const Color(0xFFA78AFF),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Catatan', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
        ],
      ),
      
    );
  }
}