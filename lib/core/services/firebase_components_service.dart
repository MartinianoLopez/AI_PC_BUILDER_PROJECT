import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';

/// 🔄 Descarga componentes desde Firebase y los organiza por categoría
Future<Map<String, List<Component>>> fetchComponentsFromFirestore(
  Map<String, Map<String, double>> rangosPorCategoria,
) async {
  final firestore = FirebaseFirestore.instance;

  final categorias = [
    'procesador_amd',
    'procesador_intel',
    'motherboard_amd',
    'motherboard_intel',
    'memoria_ram',
    'ssd',
    'placa_video',
    'gabinete',
    'fuente',
  ];

  final Map<String, List<Component>> resultado = {};

  for (final cat in categorias) {
    final rango = rangosPorCategoria[cat];

    if (rango == null || rango['min'] == null || rango['max'] == null) {
      
      print('⚠️ Rango inválido para $cat. Se omite.');
      continue;
    }

    final double precioMin = rango['min']!;
    final double precioMax = rango['max']!;

    final querySnapshot = await firestore
        .collection('productos_try')
        .doc(cat)
        .collection('items')
        .where('precio', isGreaterThanOrEqualTo: precioMin)
        .where('precio', isLessThanOrEqualTo: precioMax)
        .orderBy('precio')
        .get();

    final List<Component> componentes = [];

    for (final doc in querySnapshot.docs) {
      final data = doc.data();

      componentes.add(
        Component(
          id: doc.id,
          name: data['titulo'] ?? '',
          price: (data['precio'] as num).toDouble(),
          link: data['enlace'] ?? '',
          image: data['imagen'],
        ),
      );
    }

    resultado[cat] = componentes;
  }

  print('✅ Componentes descargados y filtrados por precio');
  return resultado;
}
