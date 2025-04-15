import 'package:ai_pc_builder_project/data_source/components_hardcode.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Components extends StatefulWidget {
  const Components({super.key, required this.initialBudget});
  final int initialBudget;

  @override
  State<Components> createState() => _ComponentsState();
  
}

class _ComponentsState extends State<Components> {
  late int budget;

  @override
 void initState() {
    super.initState();
    budget = widget.initialBudget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: [
          Text(
            'Budget: $budget',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
      ),
      body: _ComponentsLists(),
      bottomNavigationBar: _RouteButtons(),

    );
  }
}
class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      color: const Color.fromARGB(255, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              context.push('/ComponentsLinks');
            },
            child: const Text('Ver Links'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}



class _ComponentsLists extends StatelessWidget {
  _ComponentsLists();

  final List<String> componentsjson = [
    'CPU',
    'GPU',
    'Mother',
    'Memory',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: componentsjson.length,
      itemBuilder: (context, index) {
        return _ComponentTypeCard(
          name: componentsjson[index],
          );
      },
    );
  }
}


class _ComponentTypeCard extends StatelessWidget {
  const _ComponentTypeCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
      ),
    );
  }
}

