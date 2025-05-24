import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/openai_service.dart';

Future<String> checkCompatibilityWithAI(List<Component> components) async {
  final componentsDescription = components
      .map((c) => "- ${c.name} (\$${c.price.toStringAsFixed(2)} ARS)")
      .join("\n");

  final messages = [
    {
      "role": "system",
      "content": '''
Sos un experto en hardware de PC. Vas a recibir una lista de componentes y tenés que verificar:
- Compatibilidad de socket entre CPU y placa madre
- Compatibilidad de RAM
- Fuente suficiente
- Cuello de botella GPU/CPU
- Advertencias importantes o sugerencias de mejora

Respondé en forma clara, incluso si no hay errores.
'''
    },
    {
      "role": "user",
      "content": '''
Estos son los componentes:
$componentsDescription

¿Hay algo que deba saber antes de guardar este armado?
'''
    }
  ];

  final openAI = OpenAIService();
  final respuesta = await openAI.sendPrompt(messages);

  if (respuesta.trim().isEmpty) {
    return "✅ No se detectaron incompatibilidades. El armado parece correcto.";
  }

  return respuesta;
}
