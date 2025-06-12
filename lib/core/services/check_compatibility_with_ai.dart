import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/openai_service.dart';

Future<Map<String, dynamic>> checkCompatibilityWithAI(
  List<Component> components,
  List<String> categorias,
) async {
  final componentsDescription = components
      .map((c) => "- ${c.name} (\$${c.price.toStringAsFixed(2)} ARS)")
      .join("\n");

  final messages = [
    {
      "role": "system",
      "content": '''
Sos un experto en hardware de PC. Vas a recibir una lista de componentes.

Dividí la respuesta en dos partes:
1. Analizá CADA COMPONENTE por separado. Indicá si es compatible y posibles mejoras. Usá el nombre o categoría para identificarlo.
2. Al final, hacé un análisis general del armado completo.

El formato debe ser este:

[ANÁLISIS INDIVIDUAL]
Procesador: Compatible con la motherboard.
RAM: Podría aumentarse a 16GB para mejor rendimiento.
...

[ANÁLISIS GENERAL]
El armado está bien balanceado. Considerar fuente de mejor calidad.
''',
    },
    {
      "role": "user",
      "content": '''
Estos son los componentes:
$componentsDescription

¿Podés verificar compatibilidad individual y general según el formato anterior?
''',
    },
  ];

  final openAI = OpenAIService();
  final respuesta = await openAI.sendPrompt(messages);

  String individualRaw = '';
  String general = '';
  final individualParsed = <String, String>{};

  if (respuesta.trim().isEmpty) {
    individualRaw = 'Todos los componentes parecen correctos.';
    general = '✅ No se detectaron problemas en el armado.';
  } else {
    final bloques = respuesta.split(RegExp(r'\[.*\]'));
    final etiquetas = RegExp(r'\[.*\]').allMatches(respuesta).toList();

    for (var i = 0; i < etiquetas.length; i++) {
      final titulo = etiquetas[i].group(0) ?? '';
      final contenido = bloques[i + 1].trim();

      if (titulo.toLowerCase().contains('individual')) {
        individualRaw = contenido;
      } else if (titulo.toLowerCase().contains('general')) {
        general = contenido;
      }
    }

    final lineas = individualRaw.split('\n');
    for (final linea in lineas) {
      final partes = linea.split(':');
      if (partes.length >= 2) {
        final clave = partes[0].trim().toLowerCase();
        final contenido = partes.sublist(1).join(':').trim();

        for (final categoria in categorias) {
          final catNormalizada = categoria.toLowerCase();
          if ((clave.contains('cpu') && catNormalizada.contains('procesador')) ||
              (clave.contains('procesador') && catNormalizada.contains('procesador')) ||
              (clave.contains('ram') && catNormalizada.contains('memoria')) ||
              (clave.contains('mother') && catNormalizada.contains('mother')) ||
              (clave.contains('ssd') && catNormalizada.contains('ssd')) ||
              (clave.contains('gabinete') && catNormalizada.contains('gabinete')) ||
              (clave.contains('fuente') && catNormalizada.contains('fuente')) ||
              ((clave.contains('placa') || clave.contains('gpu')) && catNormalizada.contains('video'))) {
            individualParsed[categoria] = contenido;
            break;
          }
        }
      }
    }
  }

  return {
    'general': general,
    'individual': individualParsed,
  };
}
