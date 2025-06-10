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
    this.selectedOption,
  });

  final int initialBudget;
  final String? idArmado; // ID del documento en Firestore (armado)
  final String? nombreArmado; // nombre actual del armado (si ya existía)
  final List<Component?>? seleccionados;
  final bool esAmd;
  final String? selectedOption;

  @override
  State<ComponenetsView> createState() => _ComponentsViewState();
}

class _ComponentsViewState extends State<ComponenetsView> {
  bool loadingSaved = true;
  Map<String, String> analisisIndividual = {};
  String analisisGeneral = '';

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
        // ✅ Caso de edición: cargar armado
        provider.setAllSelected(widget.seleccionados!);
      } else {
        // ✅ Caso de armado nuevo: limpiar selección anterior
        provider.setAllSelected(
          List.filled(provider.getComponents().length, null),
        );
      }
      if (widget.selectedOption != null) {
        // para que no se auto arme cuando se abre un guardado
        final seleccionados = await autoArmadoSugerido(
          armado: provider.components,
          usarIntel: !provider.esAmd,
          budget: widget.initialBudget,
          selectedOption: widget.selectedOption,
        );
        provider.setAllSelected(seleccionados);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentsProvider>(context, listen: true);
    final total = provider.total;
    final excedido = total > budget;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Resetear sliders al salir
          provider.setAllSelected(
            List.filled(provider.getComponents().length, null),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          title: Row(
            children: [
              // Presupuesto
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Presupuesto',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '\$${NumberFormat("#,##0", "es_AR").format(budget)}',
                    style: TextStyle(
                      color:
                          excedido
                              ? Colors.redAccent
                              : const Color.fromARGB(255, 232, 230, 230),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Separador vertical
              Container(height: 30, width: 1, color: Colors.grey[700]),
              const Spacer(),
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${NumberFormat("#,##0", "es_AR").format(total)}',
                        style: TextStyle(
                          color:
                              excedido
                                  ? Colors.redAccent
                                  : const Color.fromARGB(255, 232, 230, 230),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (excedido)
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 60),
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
    final state = context.findAncestorStateOfType<_ComponentsViewState>();
    final general = state?.analisisGeneral ?? '';

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sliders
                for (var i = 0; i < components.length; i++)
                  _ComponentSlider(components: components[i], posicion: i),

                // Análisis general de IA
                if (general.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔍 Análisis general IA',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              general,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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

    // Obtenemos el análisis individual según la categoría
    final state = context.findAncestorStateOfType<_ComponentsViewState>();
    final nombreCategoria = categorias[widget.posicion];
    final textoAnalisis = state?.analisisIndividual[nombreCategoria] ?? '';

    // 🔍 Filtro para decidir si el mensaje vale la pena mostrarse
    final textoFiltrado = textoAnalisis.toLowerCase();

    final esMensajeGenerico =
        textoFiltrado.startsWith('compatible con el') ||
        textoFiltrado.startsWith('compatible con la') ||
        textoFiltrado.startsWith('es compatible con') ||
        textoFiltrado.startsWith('compatible con todos') ||
        textoFiltrado.contains('compatible con el sistema') ||
        textoFiltrado.contains('compatibles entre sí');

    final esMensajeUtil =
        textoFiltrado.contains('no es compatible con') ||
        textoFiltrado.contains('pero') ||
        textoFiltrado.contains('mejor') ||
        textoFiltrado.contains('podría') ||
        !esMensajeGenerico;

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
                            if (esMensajeUtil)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  textoAnalisis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.amber,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
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
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
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
          (_) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text("Analizando compatibilidad con IA...")),
              ],
            ),
          ),
    );

    final result = await checkCompatibilityWithAI(
      provider.seleccionados.whereType<Component>().toList(),
    );
    // 👇 Agregá estos prints acá:
    print("🧠 Análisis individual crudo:");
    print(result['individual']);

    print("📚 Categorías locales:");
    print(provider.categoriasPorMarca);
    if (!context.mounted) return;
    Navigator.of(context).pop();

    // Guardar el análisis en el estado de la pantalla
    final state = context.findAncestorStateOfType<_ComponentsViewState>();

    if (state != null) {
      // TO DO: esto deveria estar en un provider
      state.setState(() {
        state.analisisGeneral = result['general'] ?? '';
        // Parseo simple: línea a línea, separando por ':'

        final parsed = <String, String>{};
        final lineas = (result['individual'] ?? '').split('\n');
        final categorias = provider.categoriasPorMarca;

        for (final linea in lineas) {
          final partes = linea.split(':');
          if (partes.length >= 2) {
            final clave = partes[0].trim().toLowerCase();
            final contenido = partes.sublist(1).join(':').trim();

            for (final categoria in categorias) {
              final catNormalizada = categoria.toLowerCase();
              if (clave.contains('cpu') &&
                      catNormalizada.contains('procesador') ||
                  clave.contains('procesador') &&
                      catNormalizada.contains('procesador') ||
                  clave.contains('ram') && catNormalizada.contains('memoria') ||
                  clave.contains('mother') &&
                      catNormalizada.contains('mother') ||
                  clave.contains('ssd') && catNormalizada.contains('ssd') ||
                  clave.contains('gabinete') &&
                      catNormalizada.contains('gabinete') ||
                  clave.contains('fuente') &&
                      catNormalizada.contains('fuente') ||
                  clave.contains('placa') && catNormalizada.contains('video') ||
                  clave.contains('gpu') && catNormalizada.contains('video')) {
                parsed[categoria] = contenido;
                break;
              }
            }
          }
        }
        state.analisisIndividual = parsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<ComponenetsView>();
    final isEditing = screen?.idArmado != null;
    String? currentName = screen?.nombreArmado;

    return Container(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    isMobile
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.center,
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            label: Text(isEditing ? 'Actualizar' : 'Guardar'),
                            icon: Icon(Icons.save),
                            onPressed: () async {
                              final provider = Provider.of<ComponentsProvider>(
                                context,
                                listen: false,
                              );
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid;

                              if (uid == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ Usuario no logueado'),
                                  ),
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
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              () => Navigator.pop(context),
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
                                  Navigator.pop(context, true);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('❌ Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            label: const Text('Generar PC'),
                            icon: const Icon(Icons.computer),
                            onPressed: () async {
                              final provider = Provider.of<ComponentsProvider>(
                                context,
                                listen: false,
                              );

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (_) => const AlertDialog(
                                      content: Row(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(width: 20),
                                          Expanded(
                                            child: Text(
                                              "La IA está armando tu PC...",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              );

                              print(
                                "💰 Presupuesto pasado a IA: ${screen!.initialBudget}",
                              );

                              final seleccionados = await autoArmadoSugerido(
                                armado: provider.components,
                                usarIntel: !provider.esAmd,
                                budget: screen.initialBudget,
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
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Consumer<ComponentsProvider>(
                      builder:
                          (context, provider, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Intel",
                                style: TextStyle(fontSize: 16),
                              ),
                              Switch(
                                value: provider.esAmd,
                                onChanged: (_) => provider.cambiarAmdOIntel(),
                              ),
                              const Text("AMD", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                    ),
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed:
                                () => _analizarCompatibilidadConIA(context),
                            label: const Text('Analizar con IA'),
                            icon: const Icon(Icons.smart_toy),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () => context.push('/links'),
                            label: const Text('Ver Links'),
                            icon: Icon(Icons.link),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
