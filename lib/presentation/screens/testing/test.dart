import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_pc_builder_project/presentation/screens/common/menu_lateral.dart';
import 'package:ai_pc_builder_project/core/services/openai_service.dart';

Future<String> test() async {
  final res = await sendPrompt(
    "Dame una lista CORTA de componentes de PC en json",
  );
  return res;
}

class TestingSCreen extends StatefulWidget {
  const TestingSCreen({super.key});
  @override
  State<TestingSCreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingSCreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 5, 3, 26)),
      drawer: const MainDrawer(),
      body: _MainBody(),
    );
  }
}

class _MainBody extends StatefulWidget {
  const _MainBody();

  @override
  State<_MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<_MainBody> {
  final Future<String> _testText = test();
  TextEditingController inputBudget = TextEditingController();

  void generateConfiguration(String inputBudget, BuildContext context) {
    context.push('/components', extra: int.parse(inputBudget));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _testText,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = Text(snapshot.data!);
          } else {
            children = Text('No hay data');
          }
          return children;
        },
      ),
    );
  }
}
