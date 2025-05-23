// ignore_for_file: avoid_print

import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Component?>> autoArmadoSugerido({
  required List<List<Component>> armado,
  required bool usarIntel,
}) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'];
  if (apiKey == null) {
    print("❌ API KEY no encontrada");
    return [];
  }

  // Paso 1: Filtrar categorías relevantes según Intel/AMD
  List<List<Component>> filteredArmado = [];
  List<int> mapeoIndicesOriginales = [];

  for (int i = 0; i < armado.length; i++) {
    bool incluir = true;

    // Filtrado según preferencia de arquitectura
    if ((i == 0 || i == 2) && usarIntel) incluir = false;
    if ((i == 1 || i == 3) && !usarIntel) incluir = false;

    if (incluir) {
      filteredArmado.add(armado[i]);
      mapeoIndicesOriginales.add(i);
    }
  }

  // Paso 2: Armar prompt para OpenAI
  final componentesDescription = filteredArmado
      .asMap()
      .entries
      .map((entry) {
        final componentes = entry.value;
        if (componentes.length <= 1) {
          return "- Sin opciones para la categoría ${entry.key}";
        }
        return "- ${componentes.sublist(1).map((c) => "${c.name} (\$${c.price})").join("\n- ")}";
      })
      .join("\n\n");

 final systemPrompt = """
Sos un experto en armado de computadoras. Recibirás varias opciones por categoría de componentes
(Procesadores, Motherboards, Memorias RAM, etc).

Seleccioná UNO SOLO por categoría para lograr el mejor armado **compatible** posible. 
Intentá respetar el presupuesto, pero si es necesario podés excederte **moderadamente** (hasta un 45-60%).

Si no hay opciones compatibles en una categoría, podés dejarla sin seleccionar.

Respondé sólo con los nombres exactos de los componentes seleccionados. Nada más.
""";

  final userPrompt = "Estos son los componentes por categoría:\n$componentesDescription\n\nSeleccioná uno por categoría (los más compatibles entre sí).";

  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
           {"role": "system", "content": systemPrompt},
          {"role": "user", "content": userPrompt},
        ],
        "temperature": 0.4,
        "max_tokens": 500
      }),
  );

  if (response.statusCode != 200) {
    print("❌ Error de respuesta de la API: ${response.statusCode}");
    return [];
  }

  final respuesta = jsonDecode(response.body)['choices'][0]['message']['content'] as String;
  print("📩 Respuesta de IA:\n$respuesta");

  // Paso 3: Mapear componentes seleccionados a sus posiciones
  List<Component?> seleccionados = List.filled(armado.length, null);

  for (int i = 0; i < filteredArmado.length; i++) {
    final categoria = filteredArmado[i];
    final componente = categoria.firstWhere(
      (c) => respuesta.toLowerCase().contains(c.name.toLowerCase()),
      orElse: () => categoria[0],
    );
    final seleccionado = componente.id == 'none' ? null : componente;
    final indexOriginal = mapeoIndicesOriginales[i];

    seleccionados[indexOriginal] = seleccionado;
  }

  return seleccionados;
}
