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
  });

  final int initialBudget;
  final String? idArmado; // ID del documento en Firestore (armado)
  final String? nombreArmado; // nombre actual del armado (si ya existía)

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ComponentsProvider>(context, listen: false);
      provider.createArmado(budget: budget);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentsProvider>(context, listen: true);

    return Scaffold(
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
              : BuilderView(components: provider.armado),

      bottomNavigationBar: const _RouteButtons(),
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
        return _ComponentSlider(
          components: currentComponents,
          posicion: index,
        );
      },
    );
  }
}

class _ComponentSlider extends StatefulWidget {
  const _ComponentSlider({
    required this.components,
    required this.posicion,
  });

  final List<Component> components;
  final int posicion;

  @override
  State<_ComponentSlider> createState() => _ComponentSliderState();
}

class _ComponentSliderState extends State<_ComponentSlider> {
  double currentPosition = 0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ComponentsProvider>(context, listen: false);
    final selectedIndex = provider.getSelected(widget.posicion);

    currentPosition = (selectedIndex >= 0 && selectedIndex < widget.components.length) //verifica que este dentro del rango para evitar errores
        ? selectedIndex.toDouble()
        : 0;
  }


  @override
  Widget build(BuildContext context) {
    if (widget.components.isEmpty) return const SizedBox();
    final provider = Provider.of<ComponentsProvider>(context);
    final component = widget.components[currentPosition.toInt()];
    final formattedPrice = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 2,
    ).format(component.price);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // Para que el slider y texto tengan espacio flexible
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
                        value: currentPosition,
                        min: 0,
                        max:  (widget.components.length - 1).toDouble(), 
                        divisions:
                            (widget.components.length > 1)
                                ? widget.components.length
                                : null,
                        onChanged: (value) {
                          setState(() {
                            currentPosition = value;
                          });
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
                  onLongPress:
                      () => {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(component.name),
                              content: Text(
                                "\$ ${component.price.toStringAsFixed(2)}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        ),
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
                                (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 70),
                            loadingBuilder: (context, child, loadingProgress) {
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
    );
  }
}

class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<ComponenetsView>();
    final isEditing = screen?.idArmado != null;
    String? currentName = screen?.nombreArmado;

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
              //print("📩 Respuesta IA: $iaWarning");

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
                    docId: screen!.idArmado!,
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
    ElevatedButton(
      onPressed: () async {
        final provider = Provider.of<ComponentsProvider>(
          context,
          listen: false,
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(
                  child: Text("La IA está armando tu PC AMD..."),
                ),
              ],
            ),
          ),
        );

        final seleccionados = await autoArmadoSugerido(
          armado: provider.armado,
          usarIntel: false,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop(); // cerrar loading

provider.setAllSelected(seleccionados);

        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Armado AMD sugerido"),
            content: const Text(
              "La IA ha generado una configuración compatible basada en componentes AMD. Podés revisarla y ajustarla si lo deseás.",
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
      child: const Text('PC AMD'),
    ),
    const SizedBox(width: 8),
    ElevatedButton(
      onPressed: () async {
        final provider = Provider.of<ComponentsProvider>(
          context,
          listen: false,
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(
                  child: Text("La IA está armando tu PC Intel..."),
                ),
              ],
            ),
          ),
        );

        final seleccionados = await autoArmadoSugerido(
          armado: provider.armado,
          usarIntel: true,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
        provider.setAllSelected(seleccionados);

        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Armado Intel sugerido"),
            content: const Text(
              "La IA ha generado una configuración compatible basada en componentes Intel. Podés revisarla y ajustarla si lo deseás.",
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
      child: const Text('PC Intel'),
    ),
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
