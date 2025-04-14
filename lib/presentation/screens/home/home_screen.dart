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
    context.push('/components', extra: inputBudget);
  }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 5, 3, 26),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 5, 3, 26),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 9, 11, 14)),
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
              onTap: () => context.go('/ComponentsLinks'),
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
              const Text('Ingresar presupuesto:'),
              const SizedBox( height: 5),
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
                    labelText: '',
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: const Text('Armar PC'),
                        ),
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
