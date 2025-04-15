import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComponentsLinks extends StatelessWidget {
  const ComponentsLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Links")),

      body: _RouteButtons(),

      
    );
  }
}

class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.pop(); 
        },
        child: const Text('Volver'),
      ),
    );
  }
}
