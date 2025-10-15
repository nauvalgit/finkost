import 'package:flutter/material.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/authentication/presentation/pages/signup_page.dart'; 
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart'; 

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

  void _login() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi tidak boleh kosong')),
      );
      return;
    }

    print('Attempting to login with:');
    print('Email: $email');
    print('Password: $password');

    
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA78AFF), 
      body: SingleChildScrollView(
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
              onPressed: () {
                print('Login with Google clicked');
                
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
              onSuffixTap: () {
                print('Forgot password clicked');
                
              },
            ),
            const SizedBox(height: 40),

            
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, 
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            
            GestureDetector(
              onTap: () {
                print('Sign up link clicked');
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
            : (suffixText != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Center(
                        widthFactor: 0.0, 
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