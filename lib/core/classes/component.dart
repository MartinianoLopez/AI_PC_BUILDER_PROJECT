class Component {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String? image;

  Component({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.image,
  });
}