import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/services/firebase_components_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SearchComponentScreen extends StatefulWidget {
  final String category;

  const SearchComponentScreen({super.key, required this.category});

  @override
  State<SearchComponentScreen> createState() => _SearchComponentScreenState();
}

class _SearchComponentScreenState extends State<SearchComponentScreen> {
  late List<Component> components;
  List<Component> filteredComponents = [];
  bool isLoadingComponents = true;
  String searchQuery = '';
  List<String> names = ["Alice", "Bardo", "Charlie", "Diana", "Ethan"];

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    final result = await fetchComponentsByCategory(category: widget.category);

    setState(() {
      components = result;
      filteredComponents = result;
      isLoadingComponents = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: const Color.fromARGB(255, 5, 3, 26),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              isLoadingComponents
                  ? CircularProgressIndicator()
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SearchBar(
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        leading: const Icon(Icons.search),
                        hintText: "Buscar componente",
                        onChanged: (text) {
                          print(text);
                          setState(() {
                            searchQuery = text;
                            filteredComponents =
                                components.where((component) {
                                  return component.name.toLowerCase().contains(
                                    text.toLowerCase(),
                                  );
                                }).toList();
                          });
                        },
                      ),
                      ComponentList(components: filteredComponents),
                    ],
                  ),
        ),
      ),
    );
  }
}

class ComponentList extends StatelessWidget {
  const ComponentList({super.key, required this.components});

  final List<Component> components;

  @override
  Widget build(BuildContext context) {
    print(components);
    return Expanded(
      child: ListView.builder(
        itemCount: components.length,
        itemBuilder: (context, index) {
          final component = components[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: InkWell(
              onTap: () {
                // Agregar a currentArmado
                context.pop();
              },
              child: ListTile(
                leading: Image.network(
                  component.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
                title: Text(component.name),
                subtitle: Text(
                  '\$${NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2).format(component.price)}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
