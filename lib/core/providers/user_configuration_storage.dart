import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';

class UserConfigurationStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveConfiguration({
    required String uid,
    required String configName,
    required double total,
    required List<Component?> seleccionados,
    required bool esAmd,
  }) async {
    final armadosRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('armados');

    final snapshot = await armadosRef.get();
    if (snapshot.docs.length >= 10) {
      throw Exception('Ya tienes 10 PCs guardadas.');
    }

    final componentes =
        seleccionados
            .where((c) => c != null)
            .map(
              (c) => {
                'id': c!.id,
                'titulo': c.name,
                'precio': c.price,
                'imagen': c.image,
                'enlace': c.link,
              },
            )
            .toList();

    final data = {
      'name': configName,
      'total': total,
      'date': DateTime.now().toIso8601String(),
      'componentes': componentes,
      'esAmd': esAmd,
    };

    await armadosRef.add(data);
  }

  Future<void> deleteConfiguration({
    required String uid,
    required String docId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('armados')
        .doc(docId)
        .delete();
  }

  Future<void> updateConfiguration({
    required String uid,
    required String docId,
    required String configName,
    required double total,
    required List<Component?> seleccionados,
    required bool esAmd,
  }) async {
    final componentes =
        seleccionados
            .where((c) => c != null)
            .map(
              (c) => {
                'id': c!.id,
                'titulo': c.name,
                'precio': c.price,
                'imagen': c.image,
                'enlace': c.link,
              },
            )
            .toList();

    final data = {
      'name': configName,
      'total': total,
      'date': DateTime.now().toIso8601String(),
      'componentes': componentes,
      'esAmd': esAmd,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('armados')
        .doc(docId)
        .set(data);
  }

  Future<List<Map<String, dynamic>>> getUserConfigurations(String uid) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('armados')
            .orderBy('date', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'],
        'total': data['total'],
        'componentes': data['componentes'] ?? [],
        'esAmd': data['esAmd'] ?? true,
      };
    }).toList();
  }
}

Future<List<Component?>> mapGuardadoASeleccion(
  List componentesGuardados,
  List<List<Component>> armadoActual,
) async {
  return List.generate(armadoActual.length, (index) {
    if (index >= componentesGuardados.length) return null;

    final guardado = componentesGuardados[index];
    if (guardado == null || guardado['id'] == null) return null;

    final componente = armadoActual[index].firstWhere(
      (c) => c.id == guardado['id'],
      orElse: () => Component(id: '', name: '', price: 0, image: '', link: ''),
    );

    return componente.id.isEmpty ? null : componente;
  });
}
