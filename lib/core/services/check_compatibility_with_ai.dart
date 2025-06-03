import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/openai_service.dart';

Future<Map<String, String>> checkCompatibilityWithAI(List<Component> components) async {
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
'''
    },
    {
      "role": "user",
      "content": '''
Estos son los componentes:
$componentsDescription

¿Podés verificar compatibilidad individual y general según el formato anterior?
'''
    }
  ];

  final openAI = OpenAIService();
  final respuesta = await openAI.sendPrompt(messages);

  if (respuesta.trim().isEmpty) {
    return {
      'individual': 'Todos los componentes parecen correctos.',
      'general': '✅ No se detectaron problemas en el armado.',
    };
  }

  // Separar en bloques por encabezado
  final bloques = respuesta.split(RegExp(r'\[.*\]'));
  final etiquetas = RegExp(r'\[.*\]').allMatches(respuesta).toList();

  String individual = '', general = '';

  for (var i = 0; i < etiquetas.length; i++) {
    final titulo = etiquetas[i].group(0) ?? '';
    final contenido = bloques[i + 1].trim();

    if (titulo.toLowerCase().contains('individual')) {
      individual = contenido;
    } else if (titulo.toLowerCase().contains('general')) {
      general = contenido;
    }
  }

  return {
    'individual': individual,
    'general': general,
  };
}

