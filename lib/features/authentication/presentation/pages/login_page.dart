import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/authentication/presentation/pages/signup_page.dart';
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart';

import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_event.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI VALIDASI EMAIL SUPER KETAT (WHITELIST) ---
  bool _isValidEmail(String email) {
    // Regex ini hanya menerima domain yang terdaftar (com, id, net, org, co.id, dsb)
    // Menolak secara otomatis akhiran yang tidak terdaftar seperti .con atau .cum
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.(?:com|id|net|org|edu|gov|co\.id|my\.id|web\.id))$"
    );
    return emailRegex.hasMatch(email.toLowerCase());
  }

  void _login() {
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    // 1. Validasi Input Kosong
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Email dan kata sandi tidak boleh kosong');
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
      _showErrorSnackBar('Format domain email tidak didukung atau typo');
      return;
    }

    // 4. Pemicu BLoC untuk Sign In
    context.read<AuthBloc>().add(
      SignInRequested(email: email, password: password),
    );
  }

  // Helper untuk menampilkan pesan error dengan SnackBar gaya Floating
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            SnackBar(
              content: Text(state.error), 
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
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
                    'Log in to Finkost!',
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
                      debugPrint('Login with Google clicked');
                    },
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      height: 24.0,
                      width: 24.0,
                    ),
                    label: const Text(
                      'Log in with Google',
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
                          'Or log in with Email',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Username or Email',
                    icon: Icons.person,
                    enabled: !isLoading, 
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    suffixText: 'Forgot?',
                    onSuffixTap: isLoading ? null : () { 
                      debugPrint('Forgot password clicked');
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: isLoading ? null : _login, 
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
                            'Log in',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: isLoading ? null : () { 
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
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
    String? suffixText,
    VoidCallback? onSuffixTap,
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
            : (suffixText != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Center(
                      widthFactor: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          suffixText,
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
    );
  }
}