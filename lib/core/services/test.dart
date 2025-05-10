import 'package:ai_pc_builder_project/core/providers/openai_provider.dart';

Future<String> test() async {
  final test = OpenAIDatasource();
  final res = await test.sendPrompt(
    "Dame una lista CORTA de componentes de PC en json",
  );
  print(res);

  return res;
}
