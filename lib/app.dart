import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart';

import 'package:finkost/features/authentication/presentation/pages/welcome_page.dart';
import 'package:finkost/features/authentication/presentation/pages/login_page.dart';
import 'package:finkost/features/authentication/presentation/pages/signup_page.dart';
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart';

import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_state.dart';

class MyApp extends StatelessWidget {
  final bool seenWelcomeScreen;

  const MyApp({Key? key, required this.seenWelcomeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finkost App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
      // Definisi rute sesuai struktur file kamu
      routes: {
        '/main': (context) => const MainNavigationPage(),
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const MainNavigationPage();
          }
          
          if (state is Unauthenticated) {
            if (seenWelcomeScreen) {
              return const MainNavigationPage(); 
            } else {
              return const WelcomePage(); 
            }
          }

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}