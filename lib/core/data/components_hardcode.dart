import 'package:ai_pc_builder_project/core/classes/component.dart';

final componentList = [
  // 1. Motherboards
  [
    Component(id: '1', name: 'Prueba ASUS - B550M-A', link: 'https://prueba.com/component1', price: 135.99),
    Component(id: '2', name: 'Prueba Gigabyte - Z690 AORUS ELITE', link: 'https://prueba.com/component2', price: 229.90),
    Component(id: '3', name: 'Prueba MSI - X570 TOMAHAWK', link: 'https://prueba.com/component3', price: 199.99),
    Component(id: '4', name: 'Prueba ASRock - H610M-H', link: 'https://prueba.com/component4', price: 79.90),
    Component(id: '5', name: 'Prueba MSI - B660M PRO', link: 'https://prueba.com/component5', price: 129.90),
  ],

  // 2. CPUs
  [
    Component(id: '6', name: 'Prueba Intel - Core i7 11700K', link: 'https://prueba.com/component6', price: 320.50),
    Component(id: '7', name: 'Prueba AMD - Ryzen 5 5600X', link: 'https://prueba.com/component7', price: 199.99),
    Component(id: '8', name: 'Prueba Intel - Core i5 12400F', link: 'https://prueba.com/component8', price: 169.99),
    Component(id: '9', name: 'Prueba AMD - Ryzen 7 5800X', link: 'https://prueba.com/component9', price: 299.99),
    Component(id: '10', name: 'Prueba Intel - Core i9 13900K', link: 'https://prueba.com/component10', price: 589.99),
  ],

  // 3. GPUs
  [
    Component(id: '11', name: 'Prueba NVIDIA - GeForce GTX 1080', link: 'https://prueba.com/component11', price: 450.00),
    Component(id: '12', name: 'Prueba AMD - Radeon RX 6600 XT', link: 'https://prueba.com/component12', price: 299.99),
    Component(id: '13', name: 'Prueba NVIDIA - GeForce RTX 3060 Ti', link: 'https://prueba.com/component13', price: 399.99),
    Component(id: '14', name: 'Prueba NVIDIA - GeForce RTX 4070', link: 'https://prueba.com/component14', price: 599.99),
    Component(id: '15', name: 'Prueba AMD - Radeon RX 7900 XT', link: 'https://prueba.com/component15', price: 799.99),
  ],

  // 4. RAM
  [
    Component(id: '16', name: 'Prueba Corsair - DDR4 8GB 3200MHz', link: 'https://prueba.com/component16', price: 42.75),
    Component(id: '17', name: 'Prueba G.Skill - DDR4 16GB 3200MHz', link: 'https://prueba.com/component17', price: 74.99),
    Component(id: '18', name: 'Prueba Kingston - DDR4 32GB 3600MHz', link: 'https://prueba.com/component18', price: 129.99),
    Component(id: '19', name: 'Prueba Corsair - DDR5 16GB 5200MHz', link: 'https://prueba.com/component19', price: 149.90),
    Component(id: '20', name: 'Prueba Patriot - DDR4 8GB 3000MHz', link: 'https://prueba.com/component20', price: 38.99),
  ],

  // 5. Storage
  [
    Component(id: '21', name: 'Prueba Western Digital - SSD 1TB NVMe M.2', link: 'https://prueba.com/component21', price: 89.99),
    Component(id: '22', name: 'Prueba Crucial - SSD 500GB SATA', link: 'https://prueba.com/component22', price: 44.99),
    Component(id: '23', name: 'Prueba Seagate - HDD 1TB 7200RPM', link: 'https://prueba.com/component23', price: 49.99),
    Component(id: '24', name: 'Prueba Samsung - SSD 2TB NVMe Gen4', link: 'https://prueba.com/component24', price: 179.99),
    Component(id: '25', name: 'Prueba ADATA - SSD 250GB NVMe', link: 'https://prueba.com/component25', price: 34.99),
  ],

  // 6. Power Supplies
  [
    Component(id: '26', name: 'Prueba EVGA - 650W 80+ Bronze', link: 'https://prueba.com/component26', price: 74.99),
    Component(id: '27', name: 'Prueba Corsair - 750W 80+ Gold', link: 'https://prueba.com/component27', price: 99.99),
    Component(id: '28', name: 'Prueba Cooler Master - 500W 80+ Bronze', link: 'https://prueba.com/component28', price: 54.99),
    Component(id: '29', name: 'Prueba Seasonic - 850W Modular', link: 'https://prueba.com/component29', price: 129.99),
    Component(id: '30', name: 'Prueba SilverStone - 600W SFX', link: 'https://prueba.com/component30', price: 79.99),
  ],

  // 7. Cases
  [
    Component(id: '31', name: 'Prueba NZXT - Mid Tower ATX', link: 'https://prueba.com/component31', price: 99.00),
    Component(id: '32', name: 'Prueba Cooler Master - Mini ITX', link: 'https://prueba.com/component32', price: 89.90),
    Component(id: '33', name: 'Prueba Thermaltake - Full Tower RGB', link: 'https://prueba.com/component33', price: 149.90),
    Component(id: '34', name: 'Prueba Fractal Design - Mesh Front Panel', link: 'https://prueba.com/component34', price: 109.99),
    Component(id: '35', name: 'Prueba Phanteks - Compact ATX', link: 'https://prueba.com/component35', price: 94.50),
  ],

  // 8. Cooling
  [
    Component(id: '36', name: 'Prueba Cooler Master - Hyper 212 Black Edition', link: 'https://prueba.com/component36', price: 44.90),
    Component(id: '37', name: 'Prueba AOC - Ventilador Monitor 24"', link: 'https://prueba.com/component37', price: 129.99),
    Component(id: '38', name: 'Prueba Redragon - Teclado con Ventilación RGB', link: 'https://prueba.com/component38', price: 49.99),
    Component(id: '39', name: 'Prueba Logitech - Mouse con Enfriamiento Activo', link: 'https://prueba.com/component39', price: 59.99),
    Component(id: '40', name: 'Prueba Razer - Headset con Ventilador Integrado', link: 'https://prueba.com/component40', price: 89.99),
  ],
];
