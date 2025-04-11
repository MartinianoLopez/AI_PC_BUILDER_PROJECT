import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ai_pc_builder_project/core/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
 

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); 
    TextEditingController inputBudget = TextEditingController();

  void generateConfiguration(int inputBudget, BuildContext context){
    context.go('/components', extra: inputBudget);
  }

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
      body: Center(
        child: SizedBox(
          height: 600,
          width: 700,
          child: Column(
            
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox( height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: TextField(
                  controller: inputBudget,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],  
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ingresar Presupuesto',
                  ),
                  
                  
                ),
              ),
              const SizedBox( height: 30),
              Padding(
                
                padding: const EdgeInsets.symmetric(horizontal: 100),
          
                child: ElevatedButton(
                  onPressed: () {
                    generateConfiguration(int.parse(inputBudget.text), context);
                  }, 
                  child: 
                    Center(
                      child: const Text('Generar Configuracion')
                      )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
