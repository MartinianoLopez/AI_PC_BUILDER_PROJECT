Map<String, Map<String, double>> generarRangos(double presupuesto) {
  const variacion = 0.20;
  const distribucion = {
    'procesador_amd': 0.24,
    'procesador_intel': 0.24,
    'motherboard_amd': 0.20,
    'motherboard_intel': 0.20,
    'memoria_ram': 0.15,
    'ssd': 0.10,
    'placa_video': 0.20,
    'gabinete': 0.06,
    'fuente': 0.05,
  };

  final rangos = <String, Map<String, double>>{};

  distribucion.forEach((categoria, porcentaje) {
    final base = presupuesto * porcentaje;
    rangos[categoria] = {
      'min': 0,
      'max': base * (1 + variacion),
    };
  });

  return rangos;
}