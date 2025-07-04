import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';

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

Future<Map<String, List<Component>>> fetchComponentsFromFirestore() async {
  final Map<String, List<Component>> resultado = {};

  for (final categiria in categorias) {
    final querySnapshot =
        await firestore
            .collection('productos_try')
            .doc(categiria)
            .collection('items')
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
          image: data['imagen'] ?? '',
        ),
      );
    }

    resultado[categiria] = componentes;
  }
  print('✅ Componentes descargados y filtrados por precio');
  return resultado;
}

Future<List<Component>> fetchComponentsByCategory({
  required String category,
}) async {
  final querySnapshot =
      await firestore
          .collection('productos_try')
          .doc(category)
          .collection('items')
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
        image: data['imagen'] ?? '',
      ),
    );
  }
  return componentes;
}
