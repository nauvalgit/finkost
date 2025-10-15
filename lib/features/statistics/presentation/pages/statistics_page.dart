import 'package:flutter/material.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart'; // Pastikan path ini benar

class StatisticsPage extends StatefulWidget { // Mengubah ke StatefulWidget karena ada state untuk bulan terpilih
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedMonth = 'Jan'; // State untuk bulan yang terpilih
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang utama halaman
      // Hapus AppBar bawaan Scaffold
      // appBar: AppBar(
      //   title: const Text('Grafik'),
      //   backgroundColor: AppTheme.secondaryColor,
      // ),
      body: Column( // Menggunakan Column sebagai body utama
        children: [
          // Header Kustom (Sesuai tema Dashboard/Catatan/Kategori)
          Container(
            padding: const EdgeInsets.only(top: 48.0, bottom: 20.0, left: 16.0, right: 16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0BBE4), Color(0xFF957DAD)], // Gradient ungu Anda
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Pusatkan judul
              children: [
                const Text(
                  'Grafik', // Judul halaman
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Sisa Konten Halaman Statistik (Padding dipindahkan ke sini)
          Expanded( // Menggunakan Expanded agar sisa konten bisa discroll jika perlu
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
                          .map((month) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(month),
                                  selected: _selectedMonth == month, // Gunakan state _selectedMonth
                                  selectedColor: AppTheme.primaryColor, // Warna ketika terpilih
                                  labelStyle: TextStyle(
                                    color: _selectedMonth == month ? Colors.white : Colors.black, // Warna teks
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedMonth = month; // Update state bulan terpilih
                                      });
                                      // TODO: Lakukan fetch data statistik berdasarkan bulan terpilih
                                      print('Bulan ${month} terpilih');
                                    }
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    // TODO: Ganti Container ini dengan widget fl_chart
                    // Widget chart akan mengambil data dari BLoC
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: const Center(child: Text('Placeholder untuk Grafik')),
                    ),
                  ),
                    const SizedBox(height: 24),
                    const Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       Row(children: [CircleAvatar(radius: 8, backgroundColor: Colors.blue), SizedBox(width: 8), Text('Income')]),
                       Row(children: [CircleAvatar(radius: 8, backgroundColor: Colors.red), SizedBox(width: 8), Text('Outcome')]),
                       Row(children: [CircleAvatar(radius: 8, backgroundColor: Colors.yellow), SizedBox(width: 8), Text('Savings')]),
                     ],
                   )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}