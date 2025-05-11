import 'package:flutter/material.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/firebase_components_service.dart';

class ComponentsProvider with ChangeNotifier {
  List<List<Component>> armado = [];
  List<String> titulos = [];

  bool _cargado = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Llamado desde la vista cuando se presiona "Armar PC"
  Future<void> createArmado() async {
    if (_cargado) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await fetchComponentsFromFirestore();

      final orden = [
        "procesador_amd",
        "procesador_intel",
        "motherboard_amd",
        "motherboard_intel",
        "memoria_ram",
        "ssd",
        "placa_video",
        "gabinete",
        "fuente"
      ];

      final titulosOrdenados = [
        "Procesador AMD",
        "Procesador Intel",
        "Motherboard AMD",
        "Motherboard Intel",
        "Memoria RAM",
        "Disco (SSD/HDD)",
        "Placa de Video",
        "Gabinete",
        "Fuente de Poder"
      ];

      final List<List<Component>> ordenado = [];
      final List<String> titulosFinal = [];

      for (int i = 0; i < orden.length; i++) {
        final key = orden[i];
        final list = data[key];
        if (list != null && list.isNotEmpty) {
          ordenado.add(list);
          titulosFinal.add(titulosOrdenados[i]);
        }
      }

      armado = ordenado;
      titulos = titulosFinal;
      _cargado = true;

      print("✅ Componentes cargados: ${titulos.length} categorías");
    } catch (e) {
      print("❌ Error al crear armado: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
