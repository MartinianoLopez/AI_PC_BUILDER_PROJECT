import 'package:flutter/material.dart';

class SearchComponentScreen extends StatelessWidget {
  const SearchComponentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.search), Text("Search component")],
        ),
      ),
    );
  }
}
