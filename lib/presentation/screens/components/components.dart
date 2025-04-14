import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Components extends StatefulWidget {
  const Components({super.key});

  @override
  State<Components> createState() => _ComponentsState();
}

class _ComponentsState extends State<Components> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(



      body: Center(                  // boton de prueba
        child: SizedBox(
          child: Column(
            children: [
              const SizedBox(height: 500),

              ElevatedButton(
                  onPressed: () {
                    context.push('/ComponentsLinks'); // <- ruta como string
                  },
                  child: Center(child: Text('Ver Links'),
                  ),
                ),

                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('volver')),
                  ),
                ),
            ],
          ),
        ),
      ),




    );
  }
}
