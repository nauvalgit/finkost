import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/authentication/presentation/pages/login_page.dart';
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart';

import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_event.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI VALIDASI EMAIL SUPER KETAT ---
  bool _isValidEmail(String email) {
    // Regex ini hanya menerima domain yang terdaftar di whitelist (com, id, net, org, co.id, dsb)
    // Otomatis menolak .con, .cum, .gogle, dsb.
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.(?:com|id|net|org|edu|gov|co\.id|my\.id|web\.id))$"
    );
    return emailRegex.hasMatch(email.toLowerCase());
  }

  void _createAccount() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim().toLowerCase(); 
    final String password = _passwordController.text.trim();

    // 1. Cek Input Kosong
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Nama, Email, dan Password harus diisi');
      return;
    }

    // 2. CEK VALIDASI DOMAIN (Anti .con / .cum / .co typo)
    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Gunakan domain email valid (contoh: .com atau .id)');
      return;
    }

    // 3. Pengecekan Manual Tambahan untuk Typo spesifik
    final blockedExtensions = ['.con', '.cum', '.gogle'];
    if (blockedExtensions.any((ext) => email.endsWith(ext))) {
      _showErrorSnackBar('Format domain email tidak didukung');
      return;
    }

    // 4. Cek Panjang Password
    if (password.length < 6) {
      _showErrorSnackBar('Password minimal harus 6 karakter');
      return;
    }

    // 5. Cek Persetujuan Syarat
    if (!_agreeToTerms) {
      _showErrorSnackBar('Anda harus menyetujui syarat & ketentuan');
      return;
    }

    // Kirim data ke BLoC
    context.read<AuthBloc>().add(
      SignUpRequested(
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  // Helper untuk menampilkan pesan kesalahan
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            (Route<dynamic> route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFA78AFF),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading; 

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'Sign up to Finkost!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : () { 
                      debugPrint('Sign up with Google clicked');
                    },
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      height: 24.0,
                      width: 24.0,
                    ),
                    label: const Text(
                      'Sign up with Google',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white70)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or continue with Email',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildInputField(
                    controller: _nameController,
                    hintText: 'Enter your name',
                    icon: Icons.person_outline,
                    borderColor: AppTheme.secondaryColor,
                    enabled: !isLoading, 
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _usernameController,
                    hintText: 'Enter username',
                    icon: Icons.alternate_email,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Enter Email',
                    icon: Icons.email_outlined,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Enter password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: isLoading ? null : (bool? value) { 
                          setState(() {
                            _agreeToTerms = value!;
                          });
                        },
                        activeColor: AppTheme.secondaryColor,
                        checkColor: Colors.white,
                      ),
                      const Expanded(
                        child: Text(
                          'I agree with the Terms of Service and Privacy policy',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: isLoading ? null : _createAccount, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox( 
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text( 
                            'Create Account',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: isLoading ? null : () { 
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    Color? borderColor,
    bool enabled = true, 
  }) {
    return TextField(
      controller: controller,
      enabled: enabled, 
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderColor != null
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderColor != null
              ? BorderSide(color: borderColor, width: 2)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderColor != null
              ? BorderSide(color: borderColor, width: 2)
              : const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
    );
  }
}