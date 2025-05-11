import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ComponenetsView extends StatefulWidget {
  const ComponenetsView({super.key, required this.initialBudget});
  final int initialBudget;

  @override
  State<ComponenetsView> createState() => _ComponentsViewState();
}

class _ComponentsViewState extends State<ComponenetsView> {
  late int budget;

  @override
  void initState() {
    super.initState();
    budget = widget.initialBudget;
    final provider = Provider.of<ComponentsProvider>(context, listen: false);
    provider.createArmado();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget: \$${budget.toString()}'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : BuilderView(
              components: provider.armado,
              titulos: provider.titulos,
            ),
      bottomNavigationBar: const _RouteButtons(),
    );
  }
}

class BuilderView extends StatelessWidget {
  final List<List<Component>> components;
  final List<String> titulos;

  const BuilderView({
    super.key,
    required this.components,
    required this.titulos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: components.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                titulos[index],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _ComponentSlider(
              component: components[index],
              index: index.toString(),
            ),
          ],
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
  double currentValue = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.component.isEmpty) return const SizedBox();

    final comp = widget.component[currentValue.toInt()];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            title: Text(comp.name),
            subtitle: Slider(
              value: currentValue,
              min: 0,
              max: widget.component.length - 1,
              divisions: widget.component.length - 1,
              label: widget.component[currentValue.toInt()].name,
              onChanged: (value) {
                setState(() {
                  currentValue = value;
                });
              },
            ),
            onTap: () {
              context.go('/component-detail/${widget.index}/${comp.id}');
            },
          ),
        ],
      ),
    );
  }
}

class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              // guardar acción
            },
            child: const Text('Guardar'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // acción AMD
                },
                child: const Text('AMD'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // acción Intel
                },
                child: const Text('Intel'),
              ),
            ],
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
