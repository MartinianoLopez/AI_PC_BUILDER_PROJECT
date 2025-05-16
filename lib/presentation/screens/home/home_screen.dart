import 'dart:convert';

import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/common/menu_lateral.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_pc_builder_project/core/providers/user_configuration_storage.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 5, 3, 26)),
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
  List<Map<String, dynamic>> savedConfigurations = [];
  bool loadingSaved = true;

  TextEditingController inputBudget = TextEditingController();

  /* void generateConfiguration(String inputBudget, BuildContext context) {
    final int budget = int.parse(inputBudget);

    // Obtener el provider y llamar a 'createArmado'
    final componentsProvider = Provider.of<ComponentsProvider>(
      context,
      listen: false,
    );
    componentsProvider
        .createArmado(); // Llamamos a 'createArmado' antes de navegar

    // Navegar a la pantalla de componentes y pasar el presupuesto
    context.push('/components', extra: budget);
  }
  */

  void _loadSavedConfigurations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final storage = UserConfigurationStorage();
    final configs = await storage.getUserConfigurations(uid);

    setState(() {
      savedConfigurations = configs;
      loadingSaved = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedConfigurations();
  }

  void generateConfiguration(String inputBudget, BuildContext context) {
    final int budget = int.tryParse(inputBudget) ?? 0;

    if (budget < 399000) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Presupuesto insuficiente'),
              content: const Text(
                'Debes ingresar al menos \$399.000 para poder armar una PC completa.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final componentsProvider = Provider.of<ComponentsProvider>(
      context,
      listen: false,
    );
    componentsProvider.createArmado(budget: budget);

    context.push('/components', extra: {
  'budget': budget,
});

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          // <- Hacemos scrollable el contenido
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    child: Center(child: Text('Armar PC')),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ⬇️ Acá van tus configuraciones guardadas
              const Text(
                'Tus Armados Guardados:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: savedConfigurations.length,
                itemBuilder: (context, index) {
                  final config = savedConfigurations[index];
                  final name = config['name'] ?? 'Sin nombre';
                  final total = config['total'] ?? 0;
                  final docId =
                      config['id']; // <-- importante para editar/borrar

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.computer),
                      title: Text(name),
                      subtitle: Text(
                        'Total: \$${NumberFormat("#,##0", "es_AR").format(total)}',
                      ),
                      
                        trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.link),
      tooltip: 'Ver links',
      onPressed: () {
        final provider = Provider.of<ComponentsProvider>(context, listen: false);
        List<Component> componentesGuardados = List<Component>.from(
          (config['componentes'] as List).where((c) => c != null).map(
                (c) => Component(
                  id: c['id'] ?? '-1',
                  name: c['titulo'] ?? 'No seleccionado',
                  price: c['precio'] ?? 0,
                  image: c['imagen'] ?? '#',
                  link: c['enlace'] ?? '#',
                ),
              ),
        );

        provider.setAllSelected(componentesGuardados);
        context.push('/links');
      },
    ),
    IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Editar armado',
      onPressed: () async {
        final provider = Provider.of<ComponentsProvider>(context, listen: false);
        List<Component> componentesGuardados = List<Component>.from(
          (config['componentes'] as List).where((c) => c != null).map(
                (c) => Component(
                  id: c['id'] ?? '-1',
                  name: c['titulo'] ?? 'No seleccionado',
                  price: c['precio'] ?? 0,
                  image: c['imagen'] ?? '#',
                  link: c['enlace'] ?? '#',
                ),
              ),
        );

        provider.setAllSelected(componentesGuardados);

        context.push(
          '/components',
          extra: {
            'budget': total,
            'editId': docId,
            'name': name,
          },
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.delete),
      tooltip: 'Eliminar armado',
      onPressed: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null || docId == null) return;

        await UserConfigurationStorage().deleteConfiguration(uid: uid, docId: docId);
        setState(() {
          savedConfigurations.removeAt(index);
        });
      },
    ),
  ],
),


                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    /*return Center(
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  child: Center(child: Text('Armar PC')),
                ),
              ),
            ),
          ],
        ),
      ),
    );*/
  }
}
