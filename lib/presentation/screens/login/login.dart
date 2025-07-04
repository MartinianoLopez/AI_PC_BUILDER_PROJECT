import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  bool _showVerifyButton = false;

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final isVerified = userCredential.user?.emailVerified ?? false;

      if (isVerified) {
        if (!mounted) return;
        context.go('/home');
      } else {
        setState(() {
          _showVerifyButton = true;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verificá tu email antes de ingresar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.message}')),
      );
    }
  }

  void _sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de verificación enviado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al reenviar email: $e')));
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {bool obscure = false, int maxLength = 30, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLength: maxLength,
          onChanged: (value) {
            setState(() {
              if (value.length >= maxLength) {
                if (controller == emailController) {
                  emailError = 'Se alcanzó el máximo de $maxLength caracteres';
                } else if (controller == passwordController) {
                  passwordError = 'Se alcanzó el máximo de $maxLength caracteres';
                }
              } else {
                if (controller == emailController) emailError = null;
                if (controller == passwordController) passwordError = null;
              }
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Ingresar Mail:', 'mail', emailController,
                    maxLength: 30, errorText: emailError),
                const SizedBox(height: 16),
                _buildTextField('Ingresar Contraseña:', 'contraseña', passwordController,
                    maxLength: 10, obscure: true, errorText: passwordError),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        context.go('/registration');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Sign in'),
                    ),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 10, 10, 10),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
                if (_showVerifyButton)
                  TextButton(
                    onPressed: _sendVerificationEmail,
                    child: const Text(
                      'Reenviar email de verificación',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
