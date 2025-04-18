import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/components/common/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      ),
      drawer: const MainDrawer(),
      body: _MainBody(),
    );
  }
}





class _MainBody extends StatefulWidget {
  const _MainBody();

  @override
  State<_MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<_MainBody> {

  TextEditingController inputBudget = TextEditingController();

void generateConfiguration(String inputBudget, BuildContext context) {
      context.push('/components', extra: int.parse(inputBudget));
    }

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const SizedBox(height: 30),
            const Text('Ingresar presupuesto:'),
            const SizedBox(height: 5),
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
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ElevatedButton(
                onPressed: () {
                  generateConfiguration(inputBudget.text, context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text('Armar PC'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
