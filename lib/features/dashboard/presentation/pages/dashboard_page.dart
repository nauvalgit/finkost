import 'package:flutter/material.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/profile/presentation/pages/profile_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> transactions = []; // Tetap kosong

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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // TODO: Nanti, panggil BLoC di sini untuk mengambil data transaksi berdasarkan tanggal yang dipilih
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          _buildTransactionSectionHeader(),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Kurangi tinggi header agar konten lebih naik
    final headerHeight = MediaQuery.of(context).size.height * 0.35;

    return SliverAppBar(
      expandedHeight: headerHeight,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false, // Penting agar tidak nempel saat digulir
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            ClipPath(
              clipper: _ConcaveHeaderClipper(), // Clipper cekung
              child: Container(
                // --- PERBAIKAN: Gradasi Warna Ungu ---
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0BBE4), Color(0xFFB7A9D8)], // Gradasi ungu
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildProfileBar(context),
                    const Spacer(flex: 2), // Kurangi flex agar konten naik
                    Center(
                      child: Column(
                        children: [
                          const Text('Dana', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'RP 2.540.000', // TODO: Ganti dengan data dana asli
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3), // Kurangi flex agar konten naik
                    // Spacer untuk memberikan ruang bagi kartu summary di bawah
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSummaryCards(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          },
          child: const CircleAvatar(
            radius: 22,
            child: Icon(Icons.person), // TODO: Ganti dengan gambar profil user
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('Adit juragan kolak', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), // TODO: Ganti dengan nama user
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
          ),
        )
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 20.0;
    final spacing = 10.0;
    final cardWidth = (screenWidth - (horizontalPadding * 2) - (spacing * 2)) / 3;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _selectDate(context),
            child: _buildSummaryCardItem(
              width: cardWidth,
              content: Text(
                // Format tahun dan bulan
                "${DateFormat('yyyy', 'id_ID').format(_selectedDate)}\n${DateFormat('MMM', 'id_ID').format(_selectedDate)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
              ),
            ),
          ),
          SizedBox(width: spacing),
          _buildSummaryCardItem(
            width: cardWidth,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Flexible(child: Text('Pemasukan', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
              ],
            ),
          ),
          SizedBox(width: spacing),
          _buildSummaryCardItem(
            width: cardWidth,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_down, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Flexible(child: Text('Pengeluaran', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardItem({required double width, required Widget content}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: content,
    );
  }

  Widget _buildTransactionSectionHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Pengeluaran', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    // Karena `transactions` selalu kosong, ini akan selalu dieksekusi
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
}

class _ConcaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40); // Ubah ini untuk mengatur kedalaman cekungan
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20, // Titik kontrol di bawah untuk efek cekung
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}