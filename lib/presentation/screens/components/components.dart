import 'package:ai_pc_builder_project/data_source/components_hardcode.dart';
import 'package:ai_pc_builder_project/domain/component.dart';
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
      body: _ComponentsView(
      components: componentList,
    ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
            },
            child: const Text('Guardar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/ComponentsLinks');
            },
            child: const Text('Ver Links'),
          ),
        ],
      ),
    );
  }
}



class _ComponentsView extends StatelessWidget {
  final List<List<Component>> components;

  const _ComponentsView({required this.components});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: components.length,
      itemBuilder: (context, index) {
        return _ComponentSlider(
          component: components[index],
          index: index.toString()
          );
      },
    );
  }
}




class _ComponentSlider extends StatefulWidget {
  const _ComponentSlider({required this.component, required this.index});
  final List<Component> component;
  final String index;
  @override
  State<_ComponentSlider> createState() => _ComponentSliderState();
}


class _ComponentSliderState extends State<_ComponentSlider> {
  double currentValue = 2;

  @override
  Widget build(BuildContext context) {
    Component compontent = widget.component[currentValue.toInt()];

    return Card(
      child: ListTile(
        title: Text(compontent.name),
        subtitle: Slider(
          year2023: false,
          value: currentValue,
          min: 0,
          max: widget.component.length - 1,  
          label: currentValue.round().toString(),
          onChanged: (value) {
            setState(() {
              currentValue = value;
            });
          },
        ),
        trailing: compontent.image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(compontent.image!),
              )
            : const Icon(Icons.computer_sharp),
        onTap: () {
          context.go('/component-detail/${widget.index}/${compontent.id}');
        },
      ),
    );
  }
}
