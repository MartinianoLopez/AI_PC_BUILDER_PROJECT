import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: dotenv.env['GOOGLE_CLIENT_ID_WEB'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!context.mounted) return;
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar con Google: $e')),
      );
    }
  }

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

            // Botón Registrarse
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

            // Botón Iniciar sesión
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

            // Botón Acceder con Google (estilo unificado)
            ElevatedButton(
              onPressed: () => _signInWithGoogle(context),
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
