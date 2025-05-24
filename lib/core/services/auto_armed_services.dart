// 📁 lib/core/services/auto_armed_services.dart

import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/openai_service.dart';

Future<List<Component?>> autoArmadoSugerido({
  required List<List<Component>> armado,
  required bool usarIntel,
}) async {
  // Paso 1: Filtrar categorías relevantes
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

  // Paso 2: Armar prompt con límite dinámico
  const limiteMaxTokens = 12000;
  const largoEstimado = 25;

  int limite = (limiteMaxTokens / (filteredArmado.length * largoEstimado)).floor().clamp(5, 30);

  final componentesDescription = filteredArmado
      .asMap()
      .entries
      .map((entry) {
        final componentes = entry.value;
        if (componentes.length <= 1) {
          return "- Sin opciones para la categoría ${entry.key}";
        }
        return "- ${componentes.sublist(1).take(limite).map((c) => "${c.name} (\$${c.price})").join("\n- ")}";
      })
      .join("\n\n");

final systemPrompt = """
Sos un experto en armado de computadoras. Recibirás varias opciones por categoría de componentes.

Tu objetivo es usar el presupuesto disponible de forma inteligente, intentando utilizar entre el 90% y el 100% del total disponible. No ahorres ni elijas los más baratos a menos que sea estrictamente necesario para lograr compatibilidad.

Seleccioná UN SOLO componente por categoría, buscando la mejor relación calidad/precio, rendimiento y compatibilidad.

Si no hay opciones viables en una categoría, dejala sin seleccionar.

Respondé solo con los nombres exactos de los componentes elegidos, sin ningún texto adicional.
""";


  final userPrompt = "Estos son los componentes por categoría:\n$componentesDescription\n\nSeleccioná uno por categoría.";

  final openAI = OpenAIService();
  final respuesta = await openAI.sendPrompt([
    {"role": "system", "content": systemPrompt},
    {"role": "user", "content": userPrompt},
  ]);
  print("📨 Respuesta OpenAI:\n$respuesta");

  // Paso 3: Mapear componentes seleccionados
  List<Component?> seleccionados = List.filled(armado.length, null);

  for (int i = 0; i < filteredArmado.length; i++) {
    final categoria = filteredArmado[i];

    print("🔍 Buscando coincidencia para categoría original ${mapeoIndicesOriginales[i]}...");
    for (final c in categoria) {
      if (c.id != 'none') {
        print(" - ${c.name}");
      }
    }

    final componente = categoria.firstWhere(
      (c) => respuesta.toLowerCase().contains(c.name.toLowerCase()),
      orElse: () => categoria[0],
    );

    final seleccionado = componente.id == 'none' ? null : componente;
    final indexOriginal = mapeoIndicesOriginales[i];

    seleccionados[indexOriginal] = seleccionado;

    if (seleccionado != null) {
      print("✅ Seleccionado: ${seleccionado.name} → categoría original $indexOriginal");
    } else {
      print("⚠️ Nada seleccionado para categoría original $indexOriginal");
    }
  }

  print("🎯 Largo de armado original: ${armado.length}");
  print("🎯 Largo de seleccionados: ${seleccionados.length}");

  return seleccionados;
}
