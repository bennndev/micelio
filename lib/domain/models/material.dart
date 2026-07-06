// ──────────────────────────────────────────────
// CONFIG → Enum de materiales soportados
//       Define el contenedor y factor de CO2
// ──────────────────────────────────────────────
enum MaterialResiduo {
  plastico('Plástico', 'Azul', 3.0),
  vidrio('Vidrio', 'Verde', 0.4),
  papel('Papel / Cartón', 'Amarillo', 1.5),
  metal('Metal', 'Amarillo', 3.0),
  organico('Orgánico', 'Marrón', 0.0),
  otro('Otro', 'Gris', 0.5);

  final String displayName;
  final String contenedor;
  final double factorCO2;

  const MaterialResiduo(this.displayName, this.contenedor, this.factorCO2);

  // ──────────────────────────────────────────────
  // CALC → Obtener tipo de material desde string
  // ──────────────────────────────────────────────
  static MaterialResiduo fromString(String value) {
    return MaterialResiduo.values.firstWhere(
      (m) =>
          m.name.toLowerCase() == value.toLowerCase() ||
          m.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => MaterialResiduo.otro,
    );
  }
}
