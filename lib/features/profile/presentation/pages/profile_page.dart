import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahan untuk format input
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_event.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';
import 'package:finkost/features/authentication/presentation/pages/login_page.dart';
import 'package:finkost/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:finkost/core/utils/pdf_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _budgetController = TextEditingController();
  bool _isSavingBudget = false;
  // Format currency untuk tampilan rapi
  final _formatter = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final sekarang = DateTime.now();
    context.read<TransactionBloc>().add(
      LoadMonthlyStatistics(sekarang.year, sekarang.month),
    );
    _loadSavedBudget();
  }

  Future<void> _loadSavedBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final double savedBudget = prefs.getDouble('monthly_budget') ?? 0.0;
    if (savedBudget > 0) {
      // Menampilkan angka dengan format titik ribuan saat pertama kali dimuat
      _budgetController.text = _formatter.format(savedBudget);
    }
  }

  Future<void> _saveBudget() async {
    if (_budgetController.text.isEmpty) return;

    setState(() => _isSavingBudget = true);
    
    try {
      // Menghilangkan semua titik sebelum parsing ke double
      String cleanValue = _budgetController.text.replaceAll('.', '');
      final double budgetValue = double.tryParse(cleanValue) ?? 0.0;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_budget', budgetValue);

      if (mounted) {
        // Memicu refresh data budget di Bloc
        context.read<TransactionBloc>().add(const LoadMonthlyBudget()); 

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anggaran bulanan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        // PERBAIKAN: Langsung arahkan kembali ke Dashboard setelah berhasil simpan
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan anggaran: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSavingBudget = false);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is Authenticated) {
            return _buildAuthenticatedView(context, state.user, authBloc);
          }

          return _buildUnauthenticatedView(context);
        },
      ),
    );
  }

  Widget _buildAuthenticatedView(BuildContext context, User user, AuthBloc authBloc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- HEADER GRADASI ---
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 240,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0BBE4), Color(0xFFB7A9D8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Profil Pengguna',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              // KARTU PROFIL
              Container(
                margin: const EdgeInsets.only(top: 120, left: 24, right: 24),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                      child: user.photoURL == null ? Icon(Icons.person, size: 35, color: Colors.grey[400]) : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'Pengguna Finkost',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '-',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),

          // --- SECTION PENGATURAN ANGGARAN (FITUR BARU) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Batas Anggaran',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        // PERBAIKAN: Format angka ribuan otomatis saat user mengetik
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorInputFormatter()
                        ],
                        decoration: InputDecoration(
                          labelText: 'Set Budget Bulanan',
                          hintText: 'Masukkan nominal, contoh: 2.000.000',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isSavingBudget ? null : _saveBudget,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB7A9D8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSavingBudget 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan Anggaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION LAPORAN ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laporan Keuangan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.picture_as_pdf_rounded,
                  title: 'Download Laporan PDF',
                  subtitle: 'Simpan riwayat transaksi bulan ini',
                  iconColor: Colors.redAccent,
                  onTap: () {
                    final txState = context.read<TransactionBloc>().state;
                    if (txState is TransactionLoaded) {
                      if (txState.transactions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak ada data transaksi untuk bulan ini.')),
                        );
                        return;
                      }
                      PdfService.generateTransactionReport(
                        transactions: txState.transactions,
                        summary: txState.monthlyStatistics ?? {},
                        userName: user.displayName ?? 'Pengguna Finkost',
                        monthYear: DateFormat('MMMM yyyy', 'id').format(DateTime.now()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal memuat data transaksi.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // --- TOMBOL LOGOUT ---
          TextButton.icon(
            onPressed: () => _showLogoutDialog(context, authBloc),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Keluar dari Akun',
              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthBloc authBloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authBloc.add(SignOutRequested());
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle_outlined, size: 100, color: Colors.grey),
        const SizedBox(height: 20),
        const Text('Belum Masuk Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Silakan masuk untuk mencetak laporan PDF dan mengamankan data Anda di Cloud.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB7A9D8),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Masuk Sekarang', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// CLASS HELPER: Membuat format angka ribuan (titik) saat mengetik
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final int value = int.parse(newValue.text.replaceAll('.', ''));
    final String newText = NumberFormat.decimalPattern('id').format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}