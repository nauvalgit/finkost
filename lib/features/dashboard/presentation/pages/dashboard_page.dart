import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahan untuk budget

import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/profile/presentation/pages/profile_page.dart';

import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';
import 'package:finkost/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';
import 'package:finkost/core/utils/icon_mapper.dart';
import 'package:finkost/features/transactions/presentation/pages/add_transaction_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  DateTime _selectedDate = DateTime.now();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // Variabel baru untuk menampung budget bulanan
  double _monthlyBudget = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
    _loadBudget(); // Muat budget saat pertama kali buka
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
      _loadBudget(); // Muat ulang budget jika user baru saja kembali dari Profil
    }
  }

  // Fungsi untuk mengambil data budget dari penyimpanan lokal
  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyBudget = prefs.getDouble('monthly_budget') ?? 0.0;
    });
  }

  void _loadDashboardData() {
    // KRUSIAL: Memastikan Load menggunakan bulan yang dipilih di UI (_selectedDate)
    context.read<TransactionBloc>().add(LoadTransactionsForMonth(_selectedDate.year, _selectedDate.month));
    context.read<TransactionBloc>().add(const LoadCategories(type: 'expense'));
    context.read<TransactionBloc>().add(const LoadCategories(type: 'income'));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.month != _selectedDate.month || picked.year != _selectedDate.year) {
        setState(() {
          _selectedDate = picked;
        });
        context.read<TransactionBloc>().add(LoadTransactionsForMonth(_selectedDate.year, _selectedDate.month));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    
    // Tetap menggunakan ukuran asli Anda yang stabil
    final double calculatedMaxHeight = (screenHeight * 0.45).clamp(360.0, 500.0);
    final double calculatedMinHeight = safeAreaTop + 75;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocBuilder<TransactionBloc, TransactionState>(
        buildWhen: (previous, current) =>
            current is TransactionLoaded ||
            current is TransactionLoading ||
            current is TransactionInitial,
        builder: (context, state) {
          List<Transaction> transactions = [];
          bool isLoading = state is TransactionLoading;

          if (state is TransactionLoaded) {
            transactions = state.transactions;
          }

          double totalIncome = 0;
          double totalExpense = 0;

          // Mengambil data statistik dari state jika tersedia, jika tidak hitung manual
          if (state is TransactionLoaded && state.monthlyStatistics != null) {
            totalIncome = (state.monthlyStatistics!['income'] as num).toDouble();
            totalExpense = (state.monthlyStatistics!['expense'] as num).toDouble();
          } else {
            for (var tx in transactions) {
              if (tx.transactionType == 'income') {
                totalIncome += tx.amount;
              } else {
                totalExpense += tx.amount;
              }
            }
          }
          
          double totalBalance = totalIncome - totalExpense;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                delegate: _DashboardHeaderDelegate(
                  maxHeight: calculatedMaxHeight,
                  minHeight: calculatedMinHeight,
                  balance: totalBalance,
                  income: totalIncome,
                  expense: totalExpense,
                  monthlyBudget: _monthlyBudget, // Kirim budget ke delegate
                  currencyFormat: currencyFormat,
                  selectedDate: _selectedDate,
                  onCalendarTap: () => _selectDate(context),
                  profileBarBuilder: (context) => _buildProfileBar(context),
                  summaryCardsBuilder: (context, inc, exp) => _buildSummaryCards(context, inc, exp),
                ),
              ),
              
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySectionHeaderDelegate(
                  child: _buildTransactionSectionHeader(),
                ),
              ),

              if (isLoading && transactions.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!isLoading && transactions.isEmpty)
                _buildEmptyTransactionList()
              else
                _buildTransactionList(transactions),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionSectionHeader() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      alignment: Alignment.centerLeft,
      child: const Text(
        'Riwayat Transaksi',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileBar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = 'User';
        if (state is Authenticated) {
          displayName = state.user.displayName ?? 'User';
        }

        return Row(
          children: [
            GestureDetector(
              onTap: () async {
                // MODIFIKASI: Await navigasi agar saat kembali data di-refresh total
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
                _loadBudget(); // Refresh budget
                _loadDashboardData(); // Refresh transaksi & stats bulan terpilih
              },
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: IconButton(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, double income, double expense) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 10.0;
    final double cardWidth = (screenWidth - 40 - (spacing * 2)) / 3;
    final compactFormat = NumberFormat.compactSimpleCurrency(locale: 'id_ID', name: '');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCardItem(
          width: cardWidth,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('yyyy', 'id_ID').format(_selectedDate), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.1)),
              Text(DateFormat('MMM', 'id_ID').format(_selectedDate), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.1)),
            ],
          ),
        ),
        _buildSummaryCardItem(
          width: cardWidth,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 18),
              const Text('Masuk', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(compactFormat.format(income), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
        _buildSummaryCardItem(
          width: cardWidth,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_down, color: Colors.red, size: 18),
              const Text('Keluar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(compactFormat.format(expense), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCardItem({required double width, required Widget content}) {
    return Container(
      width: width,
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: content,
    );
  }

  Widget _buildEmptyTransactionList() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Belum ada transaksi.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const Text('Tambahkan catatan keuangan pertamamu!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = transactions[index];
          final isExpense = tx.transactionType == 'expense';
          final color = isExpense ? Colors.red : Colors.green;
          final iconSign = isExpense ? '-' : '+';
          final dateStr = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(tx.transactionDate);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Dismissible(
              key: Key(tx.id ?? index.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                if (tx.id != null) {
                  context.read<TransactionBloc>().add(DeleteTransaction(tx.id!));
                }
              },
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Hapus Transaksi?"),
                    content: const Text("Data yang dihapus tidak dapat dikembalikan."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(transaction: tx),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: FaIcon(
                        IconMapper.mapStringToIconData(tx.categoryIcon),
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(tx.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tx.description != null && tx.description!.isNotEmpty)
                          Text(tx.description!, style: const TextStyle(fontSize: 12)),
                        Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    trailing: Text(
                      '$iconSign ${currencyFormat.format(tx.amount)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }
}

class _DashboardHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final double balance;
  final double income;
  final double expense;
  final double monthlyBudget;
  final NumberFormat currencyFormat;
  final DateTime selectedDate;
  final VoidCallback onCalendarTap;
  final Widget Function(BuildContext) profileBarBuilder;
  final Widget Function(BuildContext, double, double) summaryCardsBuilder;

  _DashboardHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.balance,
    required this.income,
    required this.expense,
    required this.monthlyBudget,
    required this.currencyFormat,
    required this.selectedDate,
    required this.onCalendarTap,
    required this.profileBarBuilder,
    required this.summaryCardsBuilder,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);
    final double opacity = (1.0 - (percent * 1.1)).clamp(0.0, 1.0);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: _ConcaveHeaderClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0BBE4), Color(0xFFB7A9D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        
        Opacity(
          opacity: opacity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            profileBarBuilder(context),
                            const Spacer(flex: 1),
                            const Text('Dana', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currencyFormat.format(balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // Tracker Budget
                            if (monthlyBudget > 0) _buildOverbudgetTracker(),
                            
                            const Spacer(flex: 2),
                            summaryCardsBuilder(context, income, expense),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverbudgetTracker() {
    double usagePercent = (expense / monthlyBudget).clamp(0.0, 1.0);
    Color progressColor = Colors.greenAccent;
    
    if (usagePercent > 0.6 && usagePercent <= 0.9) {
      progressColor = Colors.orangeAccent;
    } else if (usagePercent > 0.9) {
      progressColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 30, right: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget terpakai: ${(usagePercent * 100).toStringAsFixed(0)}%', 
                style: const TextStyle(color: Colors.white, fontSize: 10)
              ),
              Text(
                'Limit: ${currencyFormat.format(monthlyBudget)}', 
                style: const TextStyle(color: Colors.white70, fontSize: 10)
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usagePercent,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;
  @override
  double get minExtent => minHeight;
  @override
  bool shouldRebuild(covariant _DashboardHeaderDelegate oldDelegate) => 
      oldDelegate.balance != balance || 
      oldDelegate.monthlyBudget != monthlyBudget ||
      oldDelegate.expense != expense;
}

class _StickySectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickySectionHeaderDelegate({required this.child});
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(child: child);
  }
  
  @override
  double get maxExtent => 60.0;
  @override
  double get minExtent => 60.0;
  @override
  bool shouldRebuild(covariant _StickySectionHeaderDelegate oldDelegate) => false;
}

class _ConcaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height + 10, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}