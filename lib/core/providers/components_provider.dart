// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/firebase_components_service.dart';
import 'dart:convert';

class ComponentsProvider with ChangeNotifier {
  List<List<Component>> armado = [];
  List<String> titulos = [];
  List<Component?> seleccionados = [];

  bool _cargado = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get total =>
      seleccionados.fold(0.0, (sum, comp) => sum + (comp?.price ?? 0));

  Future<void> createArmado({required int budget}) async {
    if (_cargado) return;

    _isLoading = true;
    notifyListeners();

    try {
      // intente generar el rango con ia, pero no genera bien y tiene muchos errores, creo que es mejor calcularlo nosotros segun la distribucion promedio y un factor de tolerancia
      //por ejemplo 30 porciento para el procesador 20 para la mother y 40 % de tolerancia.

      final response = '''
      {
        "procesador_amd": {"min": 50000.0, "max": 150000.0},
        "procesador_intel": {"min": 50000.0, "max": 150000.0},
        "motherboard_amd": {"min": 30000.0, "max": 100000.0},
        "motherboard_intel": {"min": 30000.0, "max": 100000.0},
        "memoria_ram": {"min": 40000.0, "max": 50000.0},
        "ssd": {"min": 20000.0, "max": 50000.0},
        "placa_video": {"min": 70000.0, "max": 250000.0},
        "gabinete": {"min": 15000.0, "max": 40000.0},
        "fuente": {"min": 20000.0, "max": 60000.0}
      }
      ''';

      final decoded = jsonDecode(response);

      //  Generamos los rangos esperados
      final Map<String, Map<String, double>> rangos = {};
      decoded.forEach((key, value) {
        if (value is Map<String, dynamic> &&
            value.containsKey('min') &&
            value.containsKey('max')) {
          rangos[key] = {
            'min': (value['min'] as num).toDouble(),
            'max': (value['max'] as num).toDouble(),
          };
        }
      });

      //  Usamos esos rangos para pedir los componentes
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
              name: 'Sin seleccionar',
              link: '',
              price: 0,
              image: "https://static.thenounproject.com/png/2222628-200.png",
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

    _isLoading = false;
    notifyListeners();
  }

  void setSelected(int index, Component component) {
    seleccionados[index] = component.id == 'none' ? null : component;
    notifyListeners();
  }

  int getSelectedIndex(int index) {
    final selected = seleccionados[index];
    if (selected == null) return 0;
    return armado[index].indexWhere((c) => c.id == selected.id);
  }

  void setAllSelected(List<Component> newSeleccionados) {
    seleccionados = newSeleccionados;
    notifyListeners();
  }
}
