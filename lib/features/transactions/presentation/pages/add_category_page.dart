import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Pastikan sudah di pubspec.yaml

// ---- MODEL DUMMY IKON (Nanti bisa diganti dengan daftar ikon yang lebih terstruktur) ----
class IconItem {
  final String id; // ID unik ikon
  final IconData iconData; // Data ikon FontAwesome

  IconItem({required this.id, required this.iconData});
}

// Kumpulan ikon dummy yang dikelompokkan
final Map<String, List<IconItem>> dummyIconGroups = {
  'Hiburan': [
    IconItem(id: 'gamepad', iconData: FontAwesomeIcons.gamepad),
    IconItem(id: 'ghost', iconData: FontAwesomeIcons.ghost),
    IconItem(id: 'cube', iconData: FontAwesomeIcons.cube),
    IconItem(id: 'circle', iconData: FontAwesomeIcons.circle),
    IconItem(id: 'baseballBall', iconData: FontAwesomeIcons.baseball),
    IconItem(id: 'dice', iconData: FontAwesomeIcons.dice),
    IconItem(id: 'cloud', iconData: FontAwesomeIcons.cloud),
    IconItem(id: 'windowMinimize', iconData: FontAwesomeIcons.windowMinimize),
    IconItem(id: 'rotateRight', iconData: FontAwesomeIcons.rotateRight),
    IconItem(id: 'arrowUp', iconData: FontAwesomeIcons.arrowUp),
  ],
  'Makanan': [
    IconItem(id: 'wheatAwn', iconData: FontAwesomeIcons.wheatAwn),
    IconItem(id: 'pizzaSlice', iconData: FontAwesomeIcons.pizzaSlice),
    IconItem(id: 'burger', iconData: FontAwesomeIcons.burger),
    IconItem(id: 'moneyBill', iconData: FontAwesomeIcons.moneyBill),
    IconItem(id: 'bone', iconData: FontAwesomeIcons.bone),
    IconItem(id: 'mugHot', iconData: FontAwesomeIcons.mugHot),
    IconItem(id: 'iceCream', iconData: FontAwesomeIcons.iceCream),
    IconItem(id: 'cookie', iconData: FontAwesomeIcons.cookie),
    IconItem(id: 'utensils', iconData: FontAwesomeIcons.utensils),
    IconItem(id: 'lightbulb', iconData: FontAwesomeIcons.lightbulb),
  ],
  'Kehidupan': [
    IconItem(id: 'coffee', iconData: FontAwesomeIcons.mugHot), // Contoh duplikasi ikon
    IconItem(id: 'car', iconData: FontAwesomeIcons.car),
    IconItem(id: 'book', iconData: FontAwesomeIcons.book),
    IconItem(id: 'bed', iconData: FontAwesomeIcons.bed),
    IconItem(id: 'bench', iconData: FontAwesomeIcons.chair),
    // Tambahkan lebih banyak ikon sesuai kebutuhan Anda
  ],
  // Tambahkan grup ikon lain di sini
};
// ---------------------------------------------------------------------------------


class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  bool isExpense = true; // true = Pengeluaran, false = Pemasukan
  final TextEditingController _categoryNameController = TextEditingController();
  IconData? _selectedIcon; // Ikon yang dipilih pengguna

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final String categoryName = _categoryNameController.text.trim();
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
      );
      return;
    }
    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ikon untuk kategori')),
      );
      return;
    }

    print('Menyimpan kategori baru:');
    print('Tipe: ${isExpense ? 'Pengeluaran' : 'Pemasukan'}');
    print('Nama: $categoryName');
    print('Ikon: $_selectedIcon');

    // TODO: Implementasi logika penyimpanan ke Firestore/Isar di sini
    // Setelah berhasil disimpan, mungkin pop halaman ini
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Tambahkan Kategori',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.white), // Ikon centang
                      onPressed: _saveCategory, // Panggil fungsi simpan
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Toggle Button Pengeluaran / Pemasukan
                _buildToggleButtons(),
              ],
            ),
          ),

          // Bagian Input Nama Kategori
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                hintText: 'Silakan masukkan nama kategori',
                hintStyle: TextStyle(color: const Color(0xFF957DAD).withOpacity(0.6)),
                filled: true,
                fillColor: const Color(0xFF957DAD).withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.edit, color: const Color(0xFF957DAD).withOpacity(0.8)),
              ),
              style: const TextStyle(color: Color(0xFF957DAD)),
            ),
          ),

          // Bagian Daftar Ikon
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: dummyIconGroups.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          entry.key, // Nama grup (Hiburan, Makanan, dll.)
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF957DAD),
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true, // Agar GridView tidak mengambil seluruh ruang
                        physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll GridView
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // 6 ikon per baris
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          final iconItem = entry.value[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = iconItem.iconData;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedIcon == iconItem.iconData
                                    ? const Color(0xFF957DAD).withOpacity(0.5) // Warna saat dipilih
                                    : const Color(0xFFE0BBE4).withOpacity(0.3), // Warna default
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedIcon == iconItem.iconData
                                      ? const Color(0xFF957DAD)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: FaIcon(
                                  iconItem.iconData,
                                  color: _selectedIcon == iconItem.iconData
                                      ? Colors.white
                                      : const Color(0xFF957DAD),
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10), // Jeda antar grup
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildToggleButtons sama seperti di AddTransactionPage
  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
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
}