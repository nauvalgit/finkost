import 'package:flutter/material.dart';
import 'package:finkost/core/presentation/theme/app_theme.dart';
import 'package:finkost/features/authentication/presentation/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Container(
            
            padding: const EdgeInsets.only(top: 48.0, left: 16.0, right: 16.0, bottom: 20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: [
                
                Positioned(
                  right: -50,
                  top: -50,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -20,
                  top: 20,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 0, 
                  left: 0, 
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87), 
                    onPressed: () {
                      Navigator.of(context).pop(); 
                    },
                  ),
                ),
                
                
                
                

                
                const Padding(
                  
                  padding: EdgeInsets.only(top: 40.0, left: 24.0),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GestureDetector(
              onTap: () {
                print('Kartu Masuk diklik');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Masuk, lebih seru!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}