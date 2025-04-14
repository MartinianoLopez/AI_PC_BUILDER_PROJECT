import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComponentsLinks extends StatelessWidget {
  const ComponentsLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Links")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.pop(); 
          },
          child: const Text('Volver'),
        ),
      ),

      
    );
  }
}
