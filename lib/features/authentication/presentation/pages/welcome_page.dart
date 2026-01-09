import 'package:flutter/material.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finkost/features/main_navigation/presentation/pages/main_navigation_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  Future<void> _markWelcomeScreenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenWelcomeScreen', true);
  }

  @override
  Widget build(BuildContext context) {
    _markWelcomeScreenSeen();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB7A9D8),
              Color(0xFFB7A9D8),
            ],
          ),
        ),
        child: Stack(
          children: [
            
            
            Positioned(
              top: screenHeight * 0.1,
              left: screenWidth * 0.1,
              child: _buildDotPattern(color: AppTheme.primaryColor.withOpacity(0.5)),
            ),
            Positioned(
              top: screenHeight * 0.45,
              right: screenWidth * 0.1,
              child: _buildDotPattern(color: AppTheme.primaryColor.withOpacity(0.5)),
            ),
            Positioned(
              top: screenHeight * 0.2,
              left: -screenWidth * 0.2,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0BBE4).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(screenWidth * 0.2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -screenHeight * 0.1,
              right: -screenWidth * 0.15,
              child: Transform.rotate(
                angle: 0.8,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0BBE4).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(screenWidth * 0.15),
                  ),
                ),
              ),
            ),
            
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    

                    
                    const Spacer(flex: 3),

                    const Text(
                      'Welcome to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor),
                    ),

                    const Spacer(flex: 1),

                    
                    Image.asset(
                      'assets/images/wallet.png',
                      height: screenHeight * 0.35, 
                    ),

                    const SizedBox(height: 20),

                    
                    Text(
                      'FINKOST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Dompet aman, hidup nyaman—semua\nlewat FINKOST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(flex: 4), 

                    
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const MainNavigationPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildDotPattern({required Color color}) {
    return Column(
      children: List.generate(
        4,
        (rowIndex) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: List.generate(
              4,
              (colIndex) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}