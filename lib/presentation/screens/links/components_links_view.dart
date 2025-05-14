import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ComponentsLinks extends StatelessWidget {
  const ComponentsLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final selecionados = Provider.of<ComponentsProvider>(context).seleccionados;

    return Scaffold(
      appBar: AppBar(title: const Text("Links")),

      //body links component
      body: ListView(
        scrollDirection: Axis.vertical,
        children:
            selecionados
                .where((sel) => sel != null)
                .map(
                  (sel) => _Card(
                    component:
                        sel ??
                        Component(
                          id: '-1',
                          name: "No Seleccionado",
                          link: "#",
                          price: -1,
                        ),
                  ),
                )
                .toList(),
      ),
      bottomNavigationBar: _RouteButtons(),
    );
  }
}

class _Card extends StatelessWidget {
  final Component component;

  const _Card({required this.component}) : super();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color.fromRGBO(223, 194, 75, 1),
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(component.link));
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
              child: Row(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (component.image != null)
                    Image.network(
                      component.image!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                    ),
                  Column(
                    children: [
                      SizedBox(
                        width: 270,
                        child: Text(
                          component.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: const Text(
                          "Hace click para ir a la web del componente",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 8,
              child: Icon(Icons.open_in_new, color: Colors.black),
            ),
          ],
        ),
      ),
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
          ElevatedButton(onPressed: () {}, child: const Text('Guardar')),
          ElevatedButton(onPressed: () {}, child: const Text('Compartir')),
        ],
      ),
    );
  }
}
