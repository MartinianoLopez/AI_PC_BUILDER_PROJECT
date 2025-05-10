import 'package:ai_pc_builder_project/core/classes/component.dart';

final componentList = [
  // 1. Motherboards
  [
    Component(id: '1', name: 'Motherboard B550M-A', brand: 'ASUS', price: 135.99),
    Component(id: '11', name: 'Motherboard Z690 AORUS ELITE', brand: 'Gigabyte', price: 229.90),
    Component(id: '12', name: 'Motherboard X570 TOMAHAWK', brand: 'MSI', price: 199.99),
    Component(id: '13', name: 'Motherboard H610M-H', brand: 'ASRock', price: 79.90),
    Component(id: '14', name: 'Motherboard B660M PRO', brand: 'MSI', price: 129.90),
  ],

  // 2. CPUs
  [
    Component(id: '2', name: 'Intel Core i7 11700K', brand: 'Intel', price: 320.50),
    Component(id: '15', name: 'AMD Ryzen 5 5600X', brand: 'AMD', price: 199.99),
    Component(id: '16', name: 'Intel Core i5 12400F', brand: 'Intel', price: 169.99),
    Component(id: '17', name: 'AMD Ryzen 7 5800X', brand: 'AMD', price: 299.99),
    Component(id: '18', name: 'Intel Core i9 13900K', brand: 'Intel', price: 589.99),
  ],

  // 3. GPUs
  [
    Component(id: '3', name: 'NVIDIA GeForce GTX 1080', brand: 'NVIDIA', price: 450.00),
    Component(id: '19', name: 'AMD Radeon RX 6600 XT', brand: 'AMD', price: 299.99),
    Component(id: '20', name: 'NVIDIA GeForce RTX 3060 Ti', brand: 'NVIDIA', price: 399.99),
    Component(id: '21', name: 'NVIDIA GeForce RTX 4070', brand: 'NVIDIA', price: 599.99),
    Component(id: '22', name: 'AMD Radeon RX 7900 XT', brand: 'AMD', price: 799.99),
  ],

  // 4. RAM
  [
    Component(id: '4', name: 'RAM DDR4 8GB 3200MHz', brand: 'Corsair', price: 42.75),
    Component(id: '23', name: 'RAM DDR4 16GB 3200MHz', brand: 'G.Skill', price: 74.99),
    Component(id: '24', name: 'RAM DDR4 32GB 3600MHz', brand: 'Kingston', price: 129.99),
    Component(id: '25', name: 'RAM DDR5 16GB 5200MHz', brand: 'Corsair', price: 149.90),
    Component(id: '26', name: 'RAM DDR4 8GB 3000MHz', brand: 'Patriot', price: 38.99),
  ],

  // 5. Storage
  [
    Component(id: '5', name: 'SSD 1TB NVMe M.2', brand: 'Western Digital', price: 89.99),
    Component(id: '27', name: 'SSD 500GB SATA', brand: 'Crucial', price: 44.99),
    Component(id: '28', name: 'HDD 1TB 7200RPM', brand: 'Seagate', price: 49.99),
    Component(id: '29', name: 'SSD 2TB NVMe Gen4', brand: 'Samsung', price: 179.99),
    Component(id: '30', name: 'SSD 250GB NVMe', brand: 'ADATA', price: 34.99),
  ],

  // 6. Power Supplies
  [
    Component(id: '6', name: 'Power Supply 650W 80+ Bronze', brand: 'EVGA', price: 74.99),
    Component(id: '31', name: 'Power Supply 750W 80+ Gold', brand: 'Corsair', price: 99.99),
    Component(id: '32', name: 'Power Supply 500W 80+ Bronze', brand: 'Cooler Master', price: 54.99),
    Component(id: '33', name: 'Power Supply 850W Modular', brand: 'Seasonic', price: 129.99),
    Component(id: '34', name: 'Power Supply 600W SFX', brand: 'SilverStone', price: 79.99),
  ],

  // 7. Cases
  [
    Component(id: '7', name: 'PC Case Mid Tower ATX', brand: 'NZXT', price: 99.00),
    Component(id: '35', name: 'PC Case Mini ITX', brand: 'Cooler Master', price: 89.90),
    Component(id: '36', name: 'PC Case Full Tower RGB', brand: 'Thermaltake', price: 149.90),
    Component(id: '37', name: 'PC Case Mesh Front Panel', brand: 'Fractal Design', price: 109.99),
    Component(id: '38', name: 'PC Case Compact ATX', brand: 'Phanteks', price: 94.50),
  ],

  // 8. Peripherals (cooler, monitor, keyboard)
  [
    Component(id: '8', name: 'CPU Cooler Hyper 212 Black Edition', brand: 'Cooler Master', price: 44.90),
    Component(id: '9', name: 'Monitor 24" Full HD 75Hz', brand: 'AOC', price: 129.99),
    Component(id: '10', name: 'Mechanical Keyboard RGB', brand: 'Redragon', price: 49.99),
    Component(id: '39', name: 'Gaming Mouse 16000 DPI', brand: 'Logitech', price: 59.99),
    Component(id: '40', name: 'Headset Surround 7.1', brand: 'Razer', price: 89.99),
  ],
];
