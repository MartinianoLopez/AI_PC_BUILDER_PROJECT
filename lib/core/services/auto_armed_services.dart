import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/openai_service.dart';

String normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool coincide(String a, String b) {
  a = normalizar(a);
  b = normalizar(b);

  if (a == b) return true;
  if (a.contains(b) || b.contains(a)) return true;
  final tokensA = a.split(' ').toSet();
  final tokensB = b.split(' ').toSet();
  final interseccion = tokensA.intersection(tokensB);

  return interseccion.length >= (tokensB.length * 0.6); // 60% mínimo
}

Future<List<Component?>> autoArmadoSugerido({
  required List<List<Component>> armado,
  required bool usarIntel,
  required int budget,
  String? selectedOption,
}) async {
  List<List<Component>> filteredArmado = [];
  List<int> mapeoIndicesOriginales = [];

  for (int i = 0; i < armado.length; i++) {
    bool incluir = true;
    if ((i == 0 || i == 2) && usarIntel) incluir = false;
    if ((i == 1 || i == 3) && !usarIntel) incluir = false;

    if (incluir) {
      filteredArmado.add(armado[i]);
      mapeoIndicesOriginales.add(i);
    }
  }

  const limiteMaxTokens = 12000;
  const largoEstimado = 25;

  int limite = (limiteMaxTokens / (filteredArmado.length * largoEstimado))
      .floor()
      .clamp(5, 30);

  final componentesDescription = filteredArmado
      .asMap()
      .entries
      .map((entry) {
        final componentes = entry.value;
        if (componentes.length <= 1) {
          return "- Sin opciones para la categoría ${entry.key}";
        }
        return componentes
            .sublist(1)
            .take(limite)
            .map((c) => "- ${c.name} (\$${c.price})")
            .join("\n");
      })
      .join("\n\n");

  selectedOption ??= "Uso general";
  print("tipo:$selectedOption");

  final systemPrompt = """
Sos un experto en armado de computadoras. Tu objetivo es armar la mejor PC posible con el presupuesto indicado por el usuario.

Siempre que sea posible, usá el presupuesto completo. No intentes ahorrar. No elijas componentes más baratos solo por ser económicos. Cuanto más rendimiento y calidad se logre, mejor.

Seleccioná UNO SOLO por categoría, asegurándote de que sean compatibles entre sí.

Si no hay opciones compatibles en una categoría, dejala sin seleccionar.

Respondé únicamente con los nombres exactos de los componentes elegidos, uno por línea. Podés incluir el precio entre paréntesis si querés.
""";

  final userPrompt = """
Presupuesto total: \$${budget.toString()} la voy a usar con la finalidad de: \$${selectedOption.toString()}

Estos son los componentes disponibles por categoría:

$componentesDescription

Elegí uno por categoría.
""";

  final openAI = OpenAIService();
  final respuesta = await openAI.sendPrompt([
    {"role": "system", "content": systemPrompt},
    {"role": "user", "content": userPrompt},
  ]);

  final nombresIA =
      respuesta
          .split('\n')
          .map((line) {
            final idx = line.indexOf(':');
            if (idx != -1) {
              line = line.substring(idx + 1);
            }
            return line.trim().split('(').first.trim();
          })
          .where((line) => line.isNotEmpty)
          .toList();

  List<Component?> seleccionados = List.filled(armado.length, null);

  for (int i = 0; i < filteredArmado.length; i++) {
    final categoria = filteredArmado[i];
    final indexOriginal = mapeoIndicesOriginales[i];

    print("Buscando coincidencia para categoría original $indexOriginal...");

    final match = categoria.firstWhere(
      (c) => nombresIA.any((nombreIA) => coincide(nombreIA, c.name)),
      orElse: () => categoria[0],
    );

    if (match.id == 'none' || !nombresIA.any((n) => coincide(n, match.name))) {
      print("Nada seleccionado para categoría original $indexOriginal");
      continue;
    }

    seleccionados[indexOriginal] = match;
    print("Seleccionado: ${match.name} → categoría original $indexOriginal");
  }

  return seleccionados;
}
