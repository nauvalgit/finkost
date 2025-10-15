import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';
import 'package:finkost/features/authentication/presentation/pages/welcome_page.dart';
// Halaman LoginPage tidak lagi digunakan di sini jika selalu ke WelcomePage terlebih dahulu
// import 'package:finkost/features/authentication/presentation/pages/login_page.dart';
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart';

class LottieSplashPage extends StatefulWidget {
  // seenWelcomeScreen masih diterima, tapi tidak digunakan dalam logika navigasi ini
  final bool seenWelcomeScreen;

  const LottieSplashPage({Key? key, required this.seenWelcomeScreen}) : super(key: key);

  @override
  State<LottieSplashPage> createState() => _LottieSplashPageState();
}

class _LottieSplashPageState extends State<LottieSplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Sesuaikan durasi ini dengan panjang animasi Lottie Anda
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Dapatkan status autentikasi dari AuthBloc
    final authState = context.read<AuthBloc>().state;
    
    // Logika Navigasi Akhir (Opsi 3)
    if (authState is Authenticated) {
      // Jika pengguna sudah terautentikasi (sudah login)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      );
    } else {
      // Jika pengguna belum terautentikasi (Unauthenticated),
      // SELALU arahkan ke WelcomePage setelah splash, terlepas dari seenWelcomeScreen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7A9D8), // Warna latar belakang Anda
      body: Center(
        child: Lottie.asset(
          'assets/lottie/loading.json', // PASTIKAN PATH FILE LOTTIE ANDA BENAR
          width: 500, // Sesuaikan ukuran
          height: 500, // Sesuaikan ukuran
          fit: BoxFit.contain,
          repeat: true, // Jika animasi hanya diputar sekali
          animate: true, // Pastikan animasi diputar
        ),
      ),
    );
  }
}