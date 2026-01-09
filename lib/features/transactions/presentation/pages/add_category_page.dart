import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:finkost/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:finkost/models/category_local_schema.dart';
import 'package:finkost/core/utils/icon_mapper.dart';

class AddCategoryPage extends StatefulWidget {
  final String categoryType;
  // Tambahkan parameter opsional category untuk mode Edit
  final CategoryLocalSchema? category;

  const AddCategoryPage({
    Key? key, 
    required this.categoryType, 
    this.category
  }) : super(key: key);

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _nameController = TextEditingController();
  String? _selectedIconKey;
  late bool _isExpense;

  // Getter untuk mengecek apakah dalam mode edit
  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.categoryType == 'expense';

    // Jika mode edit, isi field dengan data kategori yang sudah ada
    if (isEditMode) {
      _nameController.text = widget.category!.name;
      _selectedIconKey = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
            const Icon(Icons.person_add_disabled, size: 60, color: Color(0xFF6B1D89)),
            const SizedBox(height: 16),
            const Text("Login Diperlukan", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Kamu perlu masuk ke akun Finkost untuk mengelola kategori kustom kamu sendiri.", 
              textAlign: TextAlign.center),
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
                child: const Text("Login / Daftar", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_nameController.text.isNotEmpty && _selectedIconKey != null) {
      if (isEditMode) {
        // Logika Update
        final updatedCat = widget.category!
          ..name = _nameController.text
          ..type = _isExpense ? 'expense' : 'income'
          ..icon = _selectedIconKey;
        
        context.read<TransactionBloc>().add(UpdateCategory(updatedCat));
      } else {
        // Logika Add
        final newCat = CategoryLocalSchema.create(
          name: _nameController.text,
          type: _isExpense ? 'expense' : 'income',
          icon: _selectedIconKey,
          userId: '',
        );
        context.read<TransactionBloc>().add(AddCategory(newCat));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi nama dan pilih ikon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is TransactionAuthRequired) {
            _showAuthModal(context);
          }
        },
        buildWhen: (previous, current) => 
            current is TransactionLoading || 
            current is TransactionLoaded || 
            current is TransactionInitial,
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // --- HEADER GRADASI (TANPA CELAH) ---
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0BBE4), Color(0xFFB7A9D8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          isEditMode ? "Ubah Kategori" : "Tambahkan Kategori", 
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: _saveCategory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFancyToggleButton("Pengeluaran", true),
                        const SizedBox(width: 10),
                        _buildFancyToggleButton("Pemasukan", false),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "Nama kategori",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: FaIcon(
                              FontAwesomeIcons.tag,
                              color: Color(0xFF6B1D89),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Grid Ikon
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: IconMapper.groupedIcons.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 16),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final key = entry.value[index];
                            final isSelected = _selectedIconKey == key;
                            return InkWell(
                              onTap: () => setState(() => _selectedIconKey = key),
                              borderRadius: BorderRadius.circular(15),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF6B1D89) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: const Color(0xFF6B1D89).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : null,
                                ),
                                child: Center(
                                  child: FaIcon(
                                    IconMapper.mapStringToIconData(key),
                                    color: isSelected ? Colors.white : Colors.black54,
                                    size: 22,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFancyToggleButton(String text, bool isForExpense) {
    final isSelected = _isExpense == isForExpense;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpense = isForExpense;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B1D89) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white70,
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
}