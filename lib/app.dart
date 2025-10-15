import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Pastikan sudah ada di pubspec.yaml
import 'package:finkost/core/presentation/theme/app_theme.dart';
// Import LottieSplashPage yang baru
import 'package:finkost/features/authentication/presentation/pages/lottie_splash_page.dart';


class MyApp extends StatelessWidget {
  // seenWelcomeScreen akan dilewatkan ke LottieSplashPage, tidak lagi di MyApp
  final bool seenWelcomeScreen; // Ubah nama agar tidak bentrok dengan logika internal LottieSplashPage

  const MyApp({Key? key, required this.seenWelcomeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finkost App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // --- 2. TAMBAHKAN PROPERTI INI UNTUK MEMPERBAIKI DATE PICKER ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Mengaktifkan lokalisasi Bahasa Indonesia
      ],
      // ----------------------------------------------------------------

      // Home selalu LottieSplashPage sebagai titik masuk pertama
      home: LottieSplashPage(seenWelcomeScreen: seenWelcomeScreen),
    );
  }
}