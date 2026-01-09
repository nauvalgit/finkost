import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Untuk NumberFormat
import 'package:finkost/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:finkost/models/category_local_schema.dart';
import 'package:finkost/core/utils/icon_mapper.dart';
import 'package:finkost/features/transactions/presentation/pages/add_category_page.dart';
import 'package:finkost/features/transactions/domain/entities/transaction.dart';

class AddTransactionPage extends StatefulWidget {
  // Parameter transaction untuk mode Edit Transaksi
  final Transaction? transaction;

  const AddTransactionPage({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isExpense = true;
  CategoryLocalSchema? _selectedCategory;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  // Getter untuk mengecek apakah sedang dalam mode edit transaksi
  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    
    // Load Kategori
    context.read<TransactionBloc>().add(const LoadCategories(type: 'expense'));
    context.read<TransactionBloc>().add(const LoadCategories(type: 'income'));

    // Jika mode edit transaksi, isi field dengan data yang sudah ada
    if (isEditMode) {
      isExpense = widget.transaction!.transactionType == 'expense';
      
      // Format angka ke ribuan untuk controller
      final formatter = NumberFormat.decimalPattern('id');
      _amountController.text = formatter.format(widget.transaction!.amount.toInt());
      
      _descController.text = widget.transaction!.description ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _clearInputFields() {
    _amountController.clear();
    _descController.clear();
    setState(() {
      _selectedCategory = null;
    });
    if (isEditMode) Navigator.pop(context); // Kembali ke dashboard setelah edit
  }

  // LOGIKA BARU: Dialog Peringatan jika pengeluaran melebihi budget
  void _showOverbudgetAlert(double currentTotal, double limit, double newAmount, Transaction data) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text("Overbudget Alert!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Transaksi ini akan membuat pengeluaranmu bulan ini (${currencyFormat.format(currentTotal + newAmount)}) "
          "melebihi batas anggaran (${currencyFormat.format(limit)}).\n\nTetap simpan?",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              _executeSave(data); // Lanjutkan Simpan
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Ya, Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi pemisah untuk eksekusi kirim event ke Bloc
  void _executeSave(Transaction data) {
    if (isEditMode) {
      context.read<TransactionBloc>().add(UpdateTransaction(data));
    } else {
      context.read<TransactionBloc>().add(AddTransaction(data));
    }
  }

  void _processTransaction() {
    if (_selectedCategory == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori dan jumlah harus diisi.')),
      );
      return;
    }

    final cleanAmount = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(cleanAmount);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah tidak valid.')),
      );
      return;
    }

    final transactionData = Transaction(
      id: isEditMode ? widget.transaction!.id : null,
      firestoreId: isEditMode ? widget.transaction!.firestoreId : null,
      amount: amount,
      categoryName: _selectedCategory!.name,
      categoryIcon: _selectedCategory!.icon ?? 'question',
      transactionType: isExpense ? 'expense' : 'income',
      transactionDate: isEditMode ? widget.transaction!.transactionDate : DateTime.now(),
      description: _descController.text.isNotEmpty ? _descController.text : null,
      userId: isEditMode ? widget.transaction!.userId : '',
    );

    // LOGIKA PROTEKSI ANGGARAN: Cek status budget di Bloc State
    final state = context.read<TransactionBloc>().state;
    if (state is TransactionLoaded && isExpense) {
      double currentExpense = (state.monthlyStatistics?['expense'] as num?)?.toDouble() ?? 0.0;
      double budgetLimit = state.monthlyBudget;

      // Jika ada limit budget dan transaksi baru ini mengakibatkan overbudget
      if (budgetLimit > 0 && (currentExpense + amount) > budgetLimit) {
        _showOverbudgetAlert(currentExpense, budgetLimit, amount, transactionData);
        return;
      }
    }

    _executeSave(transactionData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECDFF3), 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0BBE4), Color(0xFFB7A9D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              isEditMode ? "Ubah Catatan" : "Tambah Catatan", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            _clearInputFields();
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is TransactionAuthRequired) {
            _showAuthModal(context);
          }
        },
        buildWhen: (previous, current) =>
            current is TransactionLoaded ||
            current is TransactionLoading ||
            current is TransactionInitial,
        builder: (context, state) {
          if (state is TransactionLoading || state is TransactionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          List<CategoryLocalSchema> categories = [];
          if (state is TransactionLoaded) {
            categories = isExpense ? state.expenseCategories : state.incomeCategories;
            
            if (isEditMode && _selectedCategory == null) {
              try {
                _selectedCategory = categories.firstWhere(
                  (cat) => cat.name == widget.transaction!.categoryName
                );
              } catch (_) {}
            }
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFancyToggleButton("Pengeluaran", true),
                    const SizedBox(width: 10),
                    _buildFancyToggleButton("Pemasukan", false),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ...categories.map((cat) {
                                return _buildCategoryRectItem(
                                  label: cat.name,
                                  icon: IconMapper.mapStringToIconData(cat.icon),
                                  isSelected: _selectedCategory == cat,
                                  onTap: () => setState(() => _selectedCategory = cat),
                                  onLongPress: () => _showCategoryOptions(cat), 
                                );
                              }).toList(),
                              _buildCategoryRectItem(
                                label: "Tambah",
                                icon: FontAwesomeIcons.plus,
                                isSelected: false,
                                isAddButton: true,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddCategoryPage(categoryType: isExpense ? 'expense' : 'income'),
                                    ),
                                  );
                                  context.read<TransactionBloc>().add(LoadCategories(type: isExpense ? 'expense' : 'income'));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedCategory != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  ThousandsSeparatorInputFormatter(),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Jumlah",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  prefixText: "Rp ",
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _descController,
                                decoration: InputDecoration(
                                  hintText: "Deskripsi",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _processTransaction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B1D89),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isEditMode ? "Simpan Perubahan" : "Simpan Transaksi",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- UI WIDGET HELPERS ---

  void _showAuthModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_person, size: 60, color: Color(0xFF6B1D89)),
            const SizedBox(height: 16),
            const Text("Login Diperlukan", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Simpan catatan keuanganmu di cloud agar tidak hilang dan dapat diakses di perangkat lain.", 
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B1D89),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Login Sekarang", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryOptions(CategoryLocalSchema category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                "Kategori: ${category.name}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Ubah Kategori"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddCategoryPage(
                        categoryType: category.type,
                        category: category,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Hapus Kategori"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteCategory(category);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteCategory(CategoryLocalSchema category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Kategori?"),
        content: Text("Apakah Anda yakin ingin menghapus kategori '${category.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(DeleteCategory(category.key.toString()));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFancyToggleButton(String text, bool isForExpense) {
    final isSelected = isExpense == isForExpense;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            isExpense = isForExpense;
            _selectedCategory = null;
            context.read<TransactionBloc>().add(LoadCategories(type: isExpense ? 'expense' : 'income'));
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B1D89) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRectItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isAddButton = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (16 * 2) - (10 * 2)) / 3;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: itemWidth,
        height: itemWidth,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple[50] : const Color(0xFF6B1D89),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: isSelected ? const Color(0xFF6B1D89) : Colors.white,
              size: 35,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6B1D89) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// CLASS HELPER: Untuk format input angka dengan pemisah ribuan
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newValueText = newValue.text.replaceAll(separator, '');
    int? value = int.tryParse(newValueText);
    if (value == null) return oldValue;
    
    final formatter = NumberFormat.decimalPattern('id');
    String newString = formatter.format(value);

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}