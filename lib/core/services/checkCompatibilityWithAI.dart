import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> checkCompatibilityWithAI(List<Component> components) async {
  final apiKey = dotenv.env['OPENAI_API_KEY'];

  if (apiKey == null) {
    

    print("API key no encontrada en .env");
    return "Error: No se encontró la clave de API.";
  }

  final componentsDescription = components.map((c) => "- ${c.name} (${c.price} ARS)").join("\n");
print("🧠 Enviando a la IA:\n$componentsDescription");
final messages = [
  {
    "role": "system",
    "content":
        "Sos un experto en hardware de PC. Vas a recibir una lista de componentes y tenés que verificar:\n"
            "- Compatibilidad de socket entre CPU y placa madre\n"
            "- Compatibilidad de RAM\n"
            "- Fuente suficiente\n"
            "- Cuello de botella GPU/CPU\n"
            "- Advertencias importantes o sugerencias de mejora\n"
            "Respondé en forma clara, incluso si no hay errores."
  },
  {
    "role": "user",
    "content": "Estos son los componentes:\n$componentsDescription\n\n¿Hay algo que deba saber antes de guardar este armado?"
  }
];

  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "model": "gpt-4",
      "messages": messages,
      "temperature": 0.4,
    }),
  );

  if (response.statusCode == 200) {
  final result = jsonDecode(response.body);
  final content = result['choices'][0]['message']['content'];

  if (content != null && content.trim().isNotEmpty) {
    return content;
  } else {
    return "✅ No se detectaron incompatibilidades. El armado parece correcto.";
  }
}

}
