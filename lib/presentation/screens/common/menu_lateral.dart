import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ai_pc_builder_project/core/providers/theme_provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Future<void> logOut() async {
      try {
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return;
        context.go('/');
      } catch (e) {
        print('Error al cerrar sesion $e');
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 9, 11, 14)),
            child: Text(
              'Menú de navegación',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.go('/'),
          ),
          // ListTile(
          //   leading: const Icon(Icons.link),
          //   title: const Text('Links'),
          //   onTap: () => context.go('/links'),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.computer),
          //   title: const Text('Components'),
          //   onTap: () => context.go('/components'),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.computer),
          //   title: const Text('Testing'),
          //   onTap: () => context.go('/testing'),
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Cerrar sesión'),
            onTap: () => logOut(),
          ),
          // SwitchListTile(
          //   title: const Text("Modo oscuro"),
          //   secondary: Icon(
          //     themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          //   ),
          //   value: themeProvider.isDarkMode,
          //   onChanged: (_) => themeProvider.toggleTheme(),
          // ),
        ],
      ),
    );
  }
}
