import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:ai_pc_builder_project/core/services/ad_mob_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_pc_builder_project/core/providers/user_configuration_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  BannerAd? _banner;

  @override
  initState() {
    super.initState();
    createBanner();
  }

  void createBanner() {
    if (kIsWeb) return;
    _banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerListener,
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 3, 26),
        scrolledUnderElevation: 0.0,
        leadingWidth: 200,
        leading: Row(
          children: [
            const SizedBox(width: 12),
            TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  context.go('/');
                } catch (e) {
                  print('Error al cerrar sesión $e');
                }
              },
            ),
          ],
        ),

        actions: [
          TextButton.icon(
            onPressed: () async {
              const url =
                  'https://ai-pc-builder-soporte-tecnico-yeb1.vercel.app/';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                print('No se pudo abrir $url');
              }
            },
            icon: const Icon(Icons.contact_mail, color: Colors.white),
            label: const Text(
              "Contáctanos",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: const _MainBody(),
      bottomNavigationBar:
          _banner == null
              ? kIsWeb == true
                  ? null
                  : Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 11, 7, 58),
                    ),
                    child: Center(child: const Text('Cargando anuncio...')),
                  )
              : Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 52,
                child: AdWidget(ad: _banner!),
              ),
    );
  }
}

class _MainBody extends StatefulWidget {
  const _MainBody();
  @override
  State<_MainBody> createState() => MainBodyState();
}

class MainBodyState extends State<_MainBody> {
  List<Map<String, dynamic>> savedConfigurations = [];
  bool loadingSaved = true;

  TextEditingController inputBudget = TextEditingController();
  String selectedOption = 'Gamer';

  final List<String> options = ['Gamer', 'Oficina', 'Educación', 'Edición'];

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ComponentsProvider>(context, listen: false);
      provider.importarComponentes();
    });
  }

  void solicitudDeIngresoAlArmador(
    String inputBudget,
    String selectedOption,
    BuildContext context,
  ) async {
    final int budget = int.tryParse(inputBudget) ?? 0;

    if (budget < 399999) {
      _mostrarAlerta(
        context,
        titulo: 'Presupuesto insuficiente',
        mensaje: 'El mínimo para hacer una PC completa es \$400.000.',
        budgetSugerido: 400000,
      );
      return;
    }

    if (budget > 5000001) {
      _mostrarAlerta(
        context,
        titulo: 'Presupuesto excedido',
        mensaje: 'El presupuesto máximo es \$5.000.000.',
        budgetSugerido: 5000000,
      );
      return;
    }
    print("home $selectedOption");
    final result = await context.push(
      '/components',
      extra: {'budget': budget, 'selectedOption': selectedOption},
    );
    if (result == true) {
      setState(() => loadingSaved = true);
      _loadSavedConfigurations();
    }
  }

  void _mostrarAlerta(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required int budgetSugerido,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(mensaje, style: const TextStyle(fontSize: 16)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final componentsProvider = Provider.of<ComponentsProvider>(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Center(
      child: SizedBox(
        width: 700,
        child: Column(
          children: [
            !isKeyboardOpen
                ? Image.asset(
                  'assets/images/Logo.png',
                  height: 300,
                  fit: BoxFit.fitHeight,
                )
                : const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: TextField(
                controller: inputBudget,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    leadingSymbol: '\$',
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                    useSymbolPadding: true,
                  ),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ingresa tu presupuesto',
                ),
              ),
            ),
            const SizedBox(height: 30),
            // -------------------------------botones de armado-----------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 48, 49, 51),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color.fromARGB(255, 210, 211, 212),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedOption,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          dropdownColor: const Color.fromARGB(255, 48, 49, 51),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedOption = newValue!;
                            });
                          },
                          items:
                              options.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          solicitudDeIngresoAlArmador(
                            inputBudget.text.replaceAll(RegExp(r'[^\d]'), ''),
                            selectedOption,
                            context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            48,
                            49,
                            51,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 210, 211, 212),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Armar PC'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //----------------------------- Armados Guardados-----------------------------
            const SizedBox(height: 30),
            const Text(
              'Tus Armados Guardados:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            if (componentsProvider.isLoading) ...[
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "cargando guardados...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            //----------------------------- Guardados-----------------------------
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedConfigurations.length,
                  itemBuilder: (context, index) {
                    final config = savedConfigurations[index];
                    final name = config['name'] ?? 'Sin nombre';
                    final total = config['total'] ?? 0 as double;
                    final docId = config['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.computer),
                        title: Text(
                          '${(config['esAmd']) ? "AMD" : "Intel"} - $name',
                        ),
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
                                final provider =
                                    Provider.of<ComponentsProvider>(
                                      context,
                                      listen: false,
                                    );
                                List<Component> componentesGuardados =
                                    List<Component>.from(
                                      (config['componentes'] as List)
                                          .where((c) => c != null)
                                          .map(
                                            (c) => Component(
                                              id: c['id'] ?? '-1',
                                              name:
                                                  c['titulo'] ??
                                                  'No seleccionado',
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
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Confirmar edición'),
                                        content: const Text(
                                          '¿Estás seguro de que querés modificar este armado?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Sí, modificar'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm != true) return;
                                if (!context.mounted) return;

                                List<Component> componentesGuardados =
                                    List<Component>.from(
                                      (config['componentes'] as List)
                                          .where((c) => c != null)
                                          .map(
                                            (c) => Component(
                                              id: c['id'] ?? '-1',
                                              name:
                                                  c['titulo'] ??
                                                  'No seleccionado',
                                              price: c['precio'] ?? 0,
                                              image: c['imagen'] ?? '#',
                                              link: c['enlace'] ?? '#',
                                            ),
                                          ),
                                    );

                                // Pasa seleccionados y esAmd al editar
                                final result = await context.push(
                                  '/components',
                                  extra: {
                                    'budget': total.round(),
                                    'editId': docId,
                                    'name': name,
                                    'seleccionados': componentesGuardados,
                                    'esAmd': config['esAmd'] ?? true,
                                  },
                                );
                                if (result == true) {
                                  setState(() => loadingSaved = true);
                                  _loadSavedConfigurations();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Eliminar armado',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Eliminar armado'),
                                        content: const Text(
                                          '¿Estás seguro de que querés eliminar este armado? Esta acción no se puede deshacer.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm != true) return;

                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null || docId == null) return;

                                await UserConfigurationStorage()
                                    .deleteConfiguration(
                                      uid: uid,
                                      docId: docId,
                                    );
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
