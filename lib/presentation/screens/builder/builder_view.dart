import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:ai_pc_builder_project/core/services/check_compatibility_with_ai.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_pc_builder_project/core/providers/user_configuration_storage.dart';

class ComponenetsView extends StatefulWidget {
  const ComponenetsView({
    super.key,
    required this.initialBudget,
    this.editId,
    this.configName,
  });

  final int initialBudget;
  final String? editId; // ID del documento en Firestore (armado)
  final String? configName; // nombre actual del armado (si ya existía)

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
    final provider = Provider.of<ComponentsProvider>(context, listen: true);

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

      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : BuilderView(
                components: provider.armado,
                titulos: provider.titulos,
              ),

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
            _ComponentSlider(component: components[index], index: index),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comp.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: currentValue,
                    min: 0,
                    max: widget.component.length - 1,
                    divisions:
                        (widget.component.length > 1)
                            ? widget.component.length - 1
                            : null,
                    onChanged: (value) {
                      setState(() {
                        currentValue = value;
                      });
                      provider.setSelected(
                        widget.index,
                        widget.component[value.toInt()],
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    if (comp.image != "")
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          comp.image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
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
    final screen = context.findAncestorWidgetOfExactType<ComponenetsView>();
    final isEditing = screen?.editId != null;
    String? currentName = screen?.configName;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            child: Text(isEditing ? 'Actualizar' : 'Guardar'),
            onPressed: () async {
              final provider = Provider.of<ComponentsProvider>(
                context,
                listen: false,
              );
              final uid = FirebaseAuth.instance.currentUser?.uid;

              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Usuario no logueado')),
                );
                return;
              }

              // Pedimos nombre solo si no vino uno existente
              if (currentName?.trim().isEmpty ?? true) {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Nombre del armado'),
                      content: TextField(
                        autofocus: true,
                        onChanged: (value) {
                          currentName = value;
                        },
                        decoration: const InputDecoration(
                          hintText: "Ej: Mi PC gamer",
                        ),
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

                if (currentName!.trim().isEmpty) return;
              }

              final initialBudget = screen?.initialBudget ?? 0;
              final total = provider.total;
              final formatter = NumberFormat("#,##0", "es_AR");

              // ⚠️ Advertencia: excede el presupuesto
              if (total > initialBudget) {
                if (!context.mounted) return;
                final continuar = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Presupuesto superado',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                        content: Text(
                          'El armado cuesta \$${formatter.format(total)}, pero ingresaste un presupuesto de \$${formatter.format(initialBudget)}.\n\n¿Deseás continuar de todos modos?',
                          style: const TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí, continuar'),
                          ),
                        ],
                      ),
                );

                if (continuar != true) return;
              }
              // 🟡 Advertencia: estás muy por debajo del presupuesto (menos del 70%)
              else if (total < initialBudget * 0.7) {
                if (!context.mounted) return;
                final continuar = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Presupuesto subutilizado',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        content: Text(
                          'Tu armado cuesta solo \$${formatter.format(total)} de los \$${formatter.format(initialBudget)} disponibles.\n\n¿Deseás continuar igualmente?',
                          style: const TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí, continuar'),
                          ),
                        ],
                      ),
                );

                if (continuar != true) return;
              }
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => AlertDialog(
                      content: Row(
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text("Analizando compatibilidad con IA..."),
                          ),
                        ],
                      ),
                    ),
              );
              final iaWarning = await checkCompatibilityWithAI(
                provider.seleccionados.whereType<Component>().toList(),
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();
              print("📩 Respuesta IA: $iaWarning");

              // ✅ Mostrar advertencia aunque no haya errores críticos
              if (iaWarning != null && iaWarning.trim().isNotEmpty) {
                if (!context.mounted) return;
                final continuarIA = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Verificación IA'),
                          ],
                        ),
                        content: Text(
                          iaWarning,
                          style: const TextStyle(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Seguir editando'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Guardar de todos modos'),
                          ),
                        ],
                      ),
                );

                if (continuarIA != true) return;
              }

              try {
                final storage = UserConfigurationStorage();

                if (isEditing) {
                  await storage.updateConfiguration(
                    uid: uid,
                    docId: screen!.editId!,
                    configName: currentName!.trim(),
                    total: provider.total,
                    seleccionados: provider.seleccionados,
                  );
                } else {
                  await storage.saveConfiguration(
                    uid: uid,
                    configName: currentName!.trim(),
                    total: provider.total,
                    seleccionados: provider.seleccionados,
                  );
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? '✅ Armado actualizado'
                            : '✅ Armado guardado',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: ${e.toString()}')),
                  );
                }
              }
            },
          ),

          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('PC AMD')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () {}, child: const Text('PC Intel')),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              context.push('/links');
            },
            child: const Text('Ver Links'),
          ),
        ],
      ),
    );
  }
}
