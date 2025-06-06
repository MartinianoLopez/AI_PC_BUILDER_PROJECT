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
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
