import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  Future<String> sendPrompt(List<Map<String, String>> messages) async {
    try {
      await dotenv.load();
      var apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null) {
        print("Error: No se encontró la clave de API.");
        return "Error: No se encontró la clave de API.";
      }

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
          "max_tokens": 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Error al consultar ChatGPT: ${response.body}');
        return '❌ Error al consultar IA. Intente nuevamente.';
      }
    } catch (e) {
      print('Excepción en sendPrompt: $e');
      return '❌ Error inesperado al consultar IA.';
    }
  }
}
