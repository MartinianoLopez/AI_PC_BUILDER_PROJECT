// ignore_for_file: avoid_print
import 'package:ai_pc_builder_project/core/services/generador_de_rangos.dart';
import 'package:flutter/material.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/firebase_components_service.dart';

class ComponentsProvider with ChangeNotifier {
  List<List<Component>> armado = [];
  List<String> titulos = [];
  List<Component?> seleccionados = [];

  bool _cargado = false;
  bool isLoading = false;

  double get total =>
      seleccionados.fold(0.0, (sum, comp) => sum + (comp?.price ?? 0));

  Future<void> createArmado({required int budget}) async {
if (_cargado) {
  
  seleccionados = List.filled(armado.length, null);
  notifyListeners();
  return;
}

isLoading = true;
notifyListeners();

    final rangos = generarRangos(budget.toDouble());

    try {
      final data = await fetchComponentsFromFirestore(rangos);

      final orden = [
        "procesador_amd",
        "procesador_intel",
        "motherboard_amd",
        "motherboard_intel",
        "memoria_ram",
        "ssd",
        "placa_video",
        "gabinete",
        "fuente",
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
        "Fuente de Poder",
      ];

      final List<List<Component>> ordenado = [];
      final List<String> titulosFinal = [];

      for (int i = 0; i < orden.length; i++) {
        final key = orden[i];
        final list = data[key];
        if (list != null) {
          final conPlaceholder = [
            Component(
              id: 'none',
              name: '${titulosOrdenados[i]} - Sin seleccionar',
              link: '',
              price: 0,
              image: 'none',
            ),
            ...list,
          ];

          ordenado.add(conPlaceholder);
          titulosFinal.add(titulosOrdenados[i]);
        }
      }

      armado = ordenado;
      titulos = titulosFinal;
      seleccionados = List.filled(armado.length, null);
      _cargado = true;

      print("✅ Componentes cargados: ${titulos.length} categorías");
    } catch (e) {
      print("❌ Error al crear armado: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  void setSelected(int index, Component component) {
    seleccionados[index] = component.id == 'none' ? null : component;
    notifyListeners();
  }

  int getSelected(int posicion) {
    final selected = seleccionados[posicion];
    if (selected == null) return 0;
    final index = armado[posicion].indexWhere((c) => c.id == selected.id);
    return index >= 0 ? index : 0; // evitar -1 porque genera un range error
  }


  void setAllSelected(List<Component?> newSeleccionados) {
  if (newSeleccionados.length != seleccionados.length) {
    print("⚠️ Tamaños desalineados: no se puede actualizar correctamente.");
    return;
  }

  seleccionados = List.from(newSeleccionados);
  notifyListeners();
}

}
