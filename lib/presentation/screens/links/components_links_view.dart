import 'package:ai_pc_builder_project/core/classes/component.dart';
import 'package:ai_pc_builder_project/core/providers/components_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ComponentsLinks extends StatefulWidget {
  const ComponentsLinks({super.key});

  @override
  State<ComponentsLinks> createState() => _ComponentsLinksState();
}

class _ComponentsLinksState extends State<ComponentsLinks> {
  late List<Component?> seleccionados = [];
  late VoidCallback listener;
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ComponentsProvider>(context, listen: false);
    seleccionados = provider.seleccionados;

    listener = () {
      if (mounted) {
        setState(() {
          seleccionados = provider.seleccionados;
        });
      }
    };

    provider.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Links")),

      //body links component
      body:
          seleccionados.isEmpty
              ? Center(child: CircularProgressIndicator(strokeWidth: 2))
              : ListView(
                scrollDirection: Axis.vertical,
                children:
                    seleccionados
                        .where((sel) => sel != null)
                        .map(
                          (sel) => _Card(
                            component:
                                sel ??
                                Component(
                                  id: '-1',
                                  name: "No Seleccionado",
                                  link: "#",
                                  image: "#",
                                  price: -1,
                                ),
                          ),
                        )
                        .toList(),
              ),
      bottomNavigationBar: _RouteButtons(components: seleccionados),
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
                  if (component.image == 'none')
                    const Icon(Icons.block, size: 70),
                  if (component.image.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        component.image,
                        width: 70,
                        height: 70,
                        cacheWidth: 140,
                        cacheHeight: 140,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 70),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 70,
                            height: 70,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Icon(Icons.image_not_supported, size: 70),
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
  final List<Component?> components;

  const _RouteButtons({required this.components}) : super();

  @override
  Widget build(BuildContext context) {
    String links = components.map((c) => c?.link ?? '').join('\n');
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              // await Clipboard.setData(ClipboardData(text: links));
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return ShareOptionsSheet(links: links);
                },
              );
            },
            child: const Text('Compartir enlaces de compra'),
          ),
        ],
      ),
    );
  }
}

class ShareOptionsSheet extends StatelessWidget {
  final String links;
  const ShareOptionsSheet({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: links));
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link),
                  const SizedBox(width: 8),
                  Text(
                    'Copiar enlaces de compra',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ShareIcon(
                icon: Icons.sms,
                label: "Mensajes",
                onTap: () {
                  final smsUri = Uri.parse('sms:?body=$links');
                  launchUrl(smsUri);
                },
              ),
              _ShareIcon(
                icon: Icons.phone,
                label: "WhatsApp",
                backgroundColor: Colors.green,
                onTap: () {
                  final whatsappUri = Uri.parse('https://wa.me/?text=$links');
                  launchUrl(whatsappUri);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _ShareIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: backgroundColor,
            child: Icon(icon, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
