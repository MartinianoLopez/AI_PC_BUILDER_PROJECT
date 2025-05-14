import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_pc_builder_project/core/providers/user_configuration_storage.dart';


class ComponenetsView extends StatefulWidget {
  const ComponenetsView({super.key, required this.initialBudget});
  final int initialBudget;

  @override
  State<ComponenetsView> createState() => _ComponentsViewState();
}

class _ComponentsViewState extends State<ComponenetsView> {
  List<Map<String, dynamic>> savedConfigurations = [];
  bool loadingSaved = true;

  late int budget;

  @override
void initState() {
  super.initState();
  budget = widget.initialBudget;

  final provider = Provider.of<ComponentsProvider>(context, listen: false);
  provider.createArmado(budget: budget);

  _loadSavedConfigurations();
}

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
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentsProvider>(context);

    return Scaffold(
     
      appBar: AppBar(
        title: Row(
          children: [
            Text('Presupuesto: \$${budget.toString()}'),
            const Spacer(),
            Text(
              'Total: \$${NumberFormat("#,##0", "es_AR").format(provider.total)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : BuilderView(
              components: provider.armado,
              titulos: provider.titulos,
            ),





// -----

      bottomNavigationBar: const _RouteButtons(),
    );
  }
}

class BuilderView extends StatelessWidget {
  final List<List<Component>> components;
  final List<String> titulos;

  const BuilderView({
    super.key,
    required this.components,
    required this.titulos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: components.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                titulos[index],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _ComponentSlider(
              component: components[index],
              index: index,
            ),
          ],
        );
      },
    );
  }
}

class _ComponentSlider extends StatefulWidget {
  const _ComponentSlider({required this.component, required this.index});
  final List<Component> component;
  final int index;

  @override
  State<_ComponentSlider> createState() => _ComponentSliderState();
}

class _ComponentSliderState extends State<_ComponentSlider> {
  double currentValue = 0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ComponentsProvider>(context, listen: false);
    final selectedIndex = provider.getSelectedIndex(widget.index);
    setState(() {
      currentValue = selectedIndex.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.component.isEmpty) return const SizedBox();

    final provider = Provider.of<ComponentsProvider>(context);
    final comp = widget.component[currentValue.toInt()];
    final formattedPrice = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 2,
    ).format(comp.price);

   /* return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(comp.name),
            subtitle: Slider(
              value: currentValue,
              min: 0,
              max: widget.component.length - 1,
              divisions: widget.component.length - 1,
              onChanged: (value) {
                setState(() {
                  currentValue = value;
                });
                provider.setSelected(widget.index, widget.component[value.toInt()]);
              },
            ),
            onTap: () {
              if (comp.id != 'none') {
                context.go('/component-detail/${widget.index}/${comp.id}');
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Precio: $formattedPrice',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );*/

return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comp.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: currentValue,
                min: 0,
                max: widget.component.length - 1,
                divisions: widget.component.length - 1,
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                  });
                  provider.setSelected(
                      widget.index, widget.component[value.toInt()]);
                },
              ),
            ),
            Column(
              children: [
                if (comp.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      comp.image!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Precio: $formattedPrice',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
);




  }
}

class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          ElevatedButton(
  onPressed: () async {
    final provider = Provider.of<ComponentsProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Usuario no logueado')),
      );
      return;
    }

    String configName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nombre del armado'),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              configName = value;
            },
            decoration: const InputDecoration(hintText: "Ej: Mi PC gamer"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (configName.trim().isEmpty) return;

    try {
      final storage = UserConfigurationStorage();
      await storage.saveConfiguration(
        uid: uid,
        configName: configName.trim(),
        total: provider.total,
        seleccionados: provider.seleccionados,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Armado guardado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  },
  child: const Text('Guardar'),
),



          /*ElevatedButton(
            onPressed: () {
              // guardar acción
            },
            child: const Text('Guardar'),
          ), */
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // acción AMD
                },
                child: const Text('PC AMD'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // acción Intel
                },
                child: const Text('PC Intel'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/ComponentsLinks');
            },
            child: const Text('Ver Links'),
          ),
        ],
      ),
    );
  }
}
