import 'package:flutter/material.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/authentication/presentation/pages/login_page.dart'; // Untuk navigasi ke LoginPage
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart'; // Untuk navigasi setelah signup

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

  void _createAccount() {
    final String name = _nameController.text.trim();
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi')),
      );
      return;
    }
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui syarat & ketentuan')),
      );
      return;
    }

    print('Attempting to create account with:');
    print('Name: $name');
    print('Username: $username');
    print('Email: $email');
    print('Password: $password');

    // TODO: Implementasi logika sign-up dengan AuthBloc/Firebase Authentication di sini
    // Untuk saat ini, kita akan langsung navigasi ke MainNavigationPage seolah-olah berhasil daftar
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      (Route<dynamic> route) => false, // Ini akan menghapus semua rute di bawah MainNavigationPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA78AFF), // Latar belakang ungu
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80), // Spasi dari atas
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

            // Tombol "Sign up with Google"
            ElevatedButton.icon(
              onPressed: () {
                print('Sign up with Google clicked');
                // TODO: Implement Google Sign-up
              },
              icon: Image.asset(
                'assets/icons/google_logo.png', // <--- Asumsi ada logo Google di sini
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

            // Divider "Or continue with Email"
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

            // Input Name
            _buildInputField(
              controller: _nameController,
              hintText: 'Enter your name',
              icon: Icons.person_outline,
              borderColor: AppTheme.secondaryColor, // Warna border biru
            ),
            const SizedBox(height: 20),

            // Input Username
            _buildInputField(
              controller: _usernameController,
              hintText: 'Enter username',
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 20),

            // Input Email
            _buildInputField(
              controller: _emailController,
              hintText: 'Enter Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),

            // Input Password
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
            ),
            const SizedBox(height: 20),

            // Checkbox "I agree with the Terms..."
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToTerms = value!;
                    });
                  },
                  activeColor: AppTheme.secondaryColor, // Warna centang
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

            // Tombol "Create Account"
            ElevatedButton(
              onPressed: _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, // Warna hitam sesuai gambar
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // Teks "Already have an account? Login"
            GestureDetector(
              onTap: () {
                print('Login link clicked');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()), // Navigasi ke LoginPage
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
                        color: AppTheme.secondaryColor, // Warna aksen untuk 'Login'
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
    Color? borderColor, // Tambahkan properti borderColor
  }) {
    return TextField(
      controller: controller,
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
              ? BorderSide(color: borderColor, width: 2) // Gunakan borderColor jika ada
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
              : const BorderSide(color: Colors.blue, width: 2), // Warna default focus
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
    );
  }
}