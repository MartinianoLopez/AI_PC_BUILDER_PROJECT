import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ai_pc_builder_project/core/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú de navegación', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => context.go('/'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Links'),
              onTap: () => context.go('/links'),
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Components'),
              onTap: () => context.go('/components'),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("Modo oscuro"),
              secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Pantalla Home'),
      ),
    );
  }
}
