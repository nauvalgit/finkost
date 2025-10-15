import 'package:flutter/material.dart';
import 'package:finkost/features/transactions/presentation/pages/add_category_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Untuk ikon, pastikan sudah ditambahkan di pubspec.yaml

// ---- MODEL DUMMY KATEGORI (Nanti akan diganti dengan data asli dari Firestore/Isar) ----
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final String type; // 'expense' atau 'income'

  CategoryItem({required this.id, required this.name, required this.icon, required this.type});
}

// Data dummy untuk Pengeluaran
final List<CategoryItem> dummyExpenseCategories = [
  CategoryItem(id: '1', name: 'Tabungan', icon: FontAwesomeIcons.wallet, type: 'expense'),
  CategoryItem(id: '2', name: 'Belanja', icon: FontAwesomeIcons.cartShopping, type: 'expense'),
  CategoryItem(id: '3', name: 'Makanan', icon: FontAwesomeIcons.utensils, type: 'expense'),
  CategoryItem(id: '4', name: 'Telepon', icon: FontAwesomeIcons.phone, type: 'expense'),
  CategoryItem(id: '5', name: 'Hiburan', icon: FontAwesomeIcons.gamepad, type: 'expense'),
  CategoryItem(id: '6', name: 'Pendidikan', icon: FontAwesomeIcons.graduationCap, type: 'expense'),
  CategoryItem(id: '7', name: 'Kecantikan', icon: FontAwesomeIcons.handSparkles, type: 'expense'),
  CategoryItem(id: '8', name: 'Olahraga', icon: FontAwesomeIcons.baseball, type: 'expense'),
  CategoryItem(id: '9', name: 'Sosial', icon: FontAwesomeIcons.users, type: 'expense'),
  CategoryItem(id: '10', name: 'Transportasi', icon: FontAwesomeIcons.bus, type: 'expense'),
  CategoryItem(id: '11', name: 'Pakaian', icon: FontAwesomeIcons.shirt, type: 'expense'),
  CategoryItem(id: '12', name: 'Mobil', icon: FontAwesomeIcons.car, type: 'expense'),
  CategoryItem(id: '13', name: 'Minuman', icon: FontAwesomeIcons.mugHot, type: 'expense'),
  CategoryItem(id: '14', name: 'Rokok', icon: FontAwesomeIcons.smoking, type: 'expense'),
  CategoryItem(id: '15', name: 'Elektronik', icon: FontAwesomeIcons.laptop, type: 'expense'),
  CategoryItem(id: '16', name: 'Bepergian', icon: FontAwesomeIcons.plane, type: 'expense'),
  CategoryItem(id: '17', name: 'Kesehatan', icon: FontAwesomeIcons.heartPulse, type: 'expense'),
  CategoryItem(id: '18', name: 'Peliharaan', icon: FontAwesomeIcons.cat, type: 'expense'),
];

// Data dummy untuk Pemasukan
final List<CategoryItem> dummyIncomeCategories = [
  CategoryItem(id: '19', name: 'uuu', icon: FontAwesomeIcons.circleQuestion, type: 'income'),
  CategoryItem(id: '20', name: 'Investasi', icon: FontAwesomeIcons.arrowTrendUp, type: 'income'),
  CategoryItem(id: '21', name: 'Gaji', icon: FontAwesomeIcons.moneyBillWave, type: 'income'),
  CategoryItem(id: '22', name: 'Penghargaan', icon: FontAwesomeIcons.award, type: 'income'),
  CategoryItem(id: '23', name: 'Paruh Waktu', icon: FontAwesomeIcons.briefcase, type: 'income'),
  CategoryItem(id: '24', name: 'Lain-lain', icon: FontAwesomeIcons.ellipsis, type: 'income'),
];
// ---------------------------------------------------------------------------------


class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // true = Pengeluaran, false = Pemasukan
  bool isExpense = true; 

  @override
  Widget build(BuildContext context) {
    // Kategori yang akan ditampilkan berdasarkan pilihan isExpense
    final List<CategoryItem> categoriesToShow = isExpense ? dummyExpenseCategories : dummyIncomeCategories;

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih seperti di gambar
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bagian App Bar Kustom (Warna Ungu Gradient)
          Container(
            padding: const EdgeInsets.only(top: 48.0, bottom: 20.0, left: 16.0, right: 16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0BBE4), Color(0xFF957DAD)], // Gradient ungu
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                   const SizedBox(width: 48),
                    const Expanded(
                      child: Text(
                        'Tambahkan Catatan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Placeholder untuk menyelaraskan 'Tambahkan' ke tengah
                    const SizedBox(width: 48), 
                  ],
                ),
                const SizedBox(height: 16),
                // Toggle Button Pengeluaran / Pemasukan
                _buildToggleButtons(),
              ],
            ),
          ),

          // Bagian Daftar Kategori
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 kolom seperti di gambar
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0, // Membuat setiap item berbentuk kotak
                ),
                itemCount: categoriesToShow.length + (isExpense ? 0 : 1), // Tambah 1 untuk Pengaturan di Pemasukan
                itemBuilder: (context, index) {
                  if (!isExpense && index == categoriesToShow.length) {
                    // Tombol 'Pengaturan' hanya di Pemasukan, dan di akhir
                    return _buildCategoryButton(
                      icon: FontAwesomeIcons.gear,
                      label: 'Tambah',
                      onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const AddCategoryPage()),
                          );
                        },
                    );
                  }
                  final category = categoriesToShow[index];
                  return _buildCategoryButton(
                    icon: category.icon,
                    label: category.name,
                    onPressed: () {
                      // Aksi ketika kategori diklik
                      print('Kategori ${category.name} (${category.type}) diklik');
                      // TODO: Navigasi ke halaman detail penambahan transaksi dengan kategori terpilih
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3), // Latar belakang transparan
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpense = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isExpense ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pengeluaran',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isExpense ? const Color(0xFF957DAD) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpense = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: !isExpense ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pemasukan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !isExpense ? const Color(0xFF957DAD) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF957DAD).withOpacity(0.1), // Warna latar belakang tombol
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF957DAD).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: const Color(0xFF957DAD), size: 30), // Ukuran ikon
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF957DAD),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}