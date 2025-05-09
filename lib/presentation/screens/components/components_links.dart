import 'package:flutter/material.dart';

class ComponentsLinks extends StatelessWidget {
  const ComponentsLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Links")),

      //body links component
      
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
            },
            child: const Text('Compartir'),
          ),
          
        ],
      ),
    );
  }
}