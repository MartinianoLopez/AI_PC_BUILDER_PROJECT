import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Components extends StatefulWidget {
  Components({super.key, required this.budget});
  int budget;

  @override
  State<Components> createState() => _ComponentsState();
}

class _ComponentsState extends State<Components> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: [
          Text(
            'Budget: ${widget.budget}',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
      ),
      body: _RouteButtons(),

    );
  }
}

class _RouteButtons extends StatelessWidget {
  const _RouteButtons();

  @override
  Widget build(BuildContext context) {
    return Center(                  
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 500),
    
            ElevatedButton(
                onPressed: () {
                  context.push('/ComponentsLinks'); 
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
    );
  }
}
