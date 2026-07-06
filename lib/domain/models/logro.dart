class Logro {
  final String? id;
  final String userId;
  final String tipoLogro;
  final String nombre;
  final String descripcion;
  final String? icono;
  final DateTime fechaObtenido;

  Logro({
    this.id,
    required this.userId,
    required this.tipoLogro,
    required this.nombre,
    required this.descripcion,
    this.icono,
    required this.fechaObtenido,
  });

  // ──────────────────────────────────────────────
  // GET → Deserializar logro de Supabase
  // ──────────────────────────────────────────────
  factory Logro.fromJson(Map<String, dynamic> json) {
    return Logro(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      tipoLogro: json['tipo_logro'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      icono: json['icono'] as String?,
      fechaObtenido: DateTime.parse(json['fecha_obtenido'] as String),
    );
  }
}
