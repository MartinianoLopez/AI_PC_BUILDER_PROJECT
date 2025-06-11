import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Logo.png', height: 150),
            const SizedBox(height: 50),

      
            ElevatedButton(
              onPressed: () => context.go('/registration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 25, 25, 25),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Registrarse'),
            ),

            const SizedBox(height: 10),

        
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 25, 25, 25),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Iniciar sesión'),
            ),

            const SizedBox(height: 30),

        
            ElevatedButton(
              onPressed: () => context.go('/login?google=1'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 25, 25, 25),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/google_icon.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text('Acceder con Google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
