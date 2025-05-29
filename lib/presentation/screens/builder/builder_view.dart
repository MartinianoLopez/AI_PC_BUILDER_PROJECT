import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:ai_pc_builder_project/core/services/auto_armed_services.dart';
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
    this.idArmado,
    this.nombreArmado,
    this.seleccionados,
    this.esAmd = true,
  });

  final int initialBudget;
  final String? idArmado; // ID del documento en Firestore (armado)
  final String? nombreArmado; // nombre actual del armado (si ya existía)
  final List<Component?>? seleccionados;
  final bool esAmd;

  @override
  State<ComponenetsView> createState() => _ComponentsViewState();
}

class _ComponentsViewState extends State<ComponenetsView> {
  bool loadingSaved = true;

  late int budget;

  @override
  void initState() {
    super.initState();
    budget = widget.initialBudget;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ComponentsProvider>(context, listen: false);

      // Restaurar AMD/Intel desde lo guardado
      provider.esAmd = widget.esAmd;

      // Importar componentes solo si aún no están cargados
      await provider.importarComponentes();

      // Restaurar selección de sliders si hay valores guardados
      if (widget.seleccionados != null && widget.seleccionados!.isNotEmpty) {
        provider.setAllSelected(widget.seleccionados!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentsProvider>(context, listen: true);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // ✅ Resetear sliders al salir
          provider.setAllSelected(
            List.filled(provider.getComponents().length, null),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Spacer(),
              Text('Presupuesto: \$${budget.toString()}'),
              const Spacer(),
              Text(
                'Total: \$${NumberFormat("#,##0", "es_AR").format(provider.total)}',
              ),
              const Spacer(),
            ],
          ),
        ),
        body:
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : BuilderView(components: provider.getComponents()),
        bottomNavigationBar: const _RouteButtons(),
      ),
    );
  }
}

class BuilderView extends StatelessWidget {
  final List<List<Component>> components;
  const BuilderView({super.key, required this.components});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: components.length,
      itemBuilder: (context, index) {
        final currentComponents = components[index];
        return _ComponentSlider(components: currentComponents, posicion: index);
      },
    );
  }
}

class _ComponentSlider extends StatefulWidget {
  const _ComponentSlider({required this.components, required this.posicion});

  final List<Component> components;
  final int posicion;

  @override
  State<_ComponentSlider> createState() => _ComponentSliderState();
}

class _ComponentSliderState extends State<_ComponentSlider> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentsProvider>(context, listen: true);
    final categorias = provider.categoriasPorMarca;

    return Consumer<ComponentsProvider>(
      builder: (context, provider, _) {
        if (widget.components.isEmpty) return const SizedBox();
        int selectedIndex = provider.getSelectedIndexParaVista(widget.posicion);
        selectedIndex =
            (selectedIndex >= 0 && selectedIndex < widget.components.length)
                ? selectedIndex
                : 0;

        final component = widget.components[selectedIndex];
        final formattedPrice = NumberFormat.currency(
          locale: 'es_AR',
          symbol: '\$',
          decimalDigits: 2,
        ).format(component.price);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: InkWell(
            onTap:
                () => context.pushNamed(
                  'search-component',
                  pathParameters: {'category': categorias[widget.posicion]},
                ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              component.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: selectedIndex.toDouble(),
                              min: 0,
                              max: (widget.components.length - 1).toDouble(),
                              divisions:
                                  widget.components.length > 1
                                      ? widget.components.length
                                      : null,
                              onChanged: (value) {
                                provider.setSelected(
                                  widget.posicion,
                                  widget.components[value.toInt()],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text(component.name),
                                  content: Text(
                                    "\$ ${component.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Column(
                          children: [
                            if (component.image == 'none')
                              const Icon(Icons.block, size: 70)
                            else if (component.image.trim().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  component.image,
                                  width: 70,
                                  height: 70,
                                  cacheWidth: 140,
                                  cacheHeight: 140,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 70,
                                      ),
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              const Icon(Icons.image_not_supported, size: 70),
                            const SizedBox(height: 4),
                            Text(
                              formattedPrice,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  Future<void> _analizarCompatibilidadConIA(BuildContext context) async {
    final provider = Provider.of<ComponentsProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text("Analizando compatibilidad con IA...")),
              ],
            ),
          ),
    );

    final iaWarning = await checkCompatibilityWithAI(
      provider.seleccionados.whereType<Component>().toList(),
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (iaWarning != null && iaWarning.trim().isNotEmpty) {
      await showDialog(
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
              content: Text(iaWarning, style: const TextStyle(fontSize: 14)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Todo compatible según IA')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<ComponenetsView>();
    final isEditing = screen?.idArmado != null;
    String? currentName = screen?.nombreArmado;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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

                  try {
                    final storage = UserConfigurationStorage();

                    if (isEditing) {
                      await storage.updateConfiguration(
                        uid: uid,
                        docId: screen!.idArmado!,
                        configName: currentName!.trim(),
                        total: provider.total,
                        seleccionados: provider.seleccionados,
                        esAmd: provider.esAmd,
                      );
                    } else {
                      await storage.saveConfiguration(
                        uid: uid,
                        configName: currentName!.trim(),
                        total: provider.total,
                        seleccionados: provider.seleccionados,
                        esAmd: provider.esAmd,
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
                      Navigator.pop(
                        context,
                        true,
                      ); // <- Esta línea hace que HomeScreen sepa que debe recargar
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
              ElevatedButton(
                onPressed: () async {
                  final provider = Provider.of<ComponentsProvider>(
                    context,
                    listen: false,
                  );

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
                                child: Text("La IA está armando tu PC..."),
                              ),
                            ],
                          ),
                        ),
                  );
                  print("💰 Presupuesto pasado a IA: ${screen!.initialBudget}");

                  final seleccionados = await autoArmadoSugerido(
                    armado: provider.components,
                    usarIntel: !provider.esAmd,
                    budget: screen!.initialBudget,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();

                  provider.setAllSelected(seleccionados);

                  if (!context.mounted) return;
                  await showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text(
                            provider.esAmd
                                ? "Armado AMD sugerido"
                                : "Armado Intel sugerido",
                          ),
                          content: Text(
                            "La IA ha generado una configuración compatible basada en componentes ${provider.esAmd ? 'AMD' : 'Intel'}. Podés revisarla y ajustarla si lo deseás.",
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('Generar PC'),
              ),
              Consumer<ComponentsProvider>(
                builder:
                    (context, provider, _) => Row(
                      children: [
                        const Text("AMD"),
                        Switch(
                          value: provider.esAmd,
                          onChanged: (_) => provider.cambiarAmdOIntel(),
                        ),
                        const Text("Intel"),
                      ],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _analizarCompatibilidadConIA(context),
                child: const Text('Analizar con IA'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/links');
                },
                child: const Text('Ver Links'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
