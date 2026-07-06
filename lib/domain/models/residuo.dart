class Residuo {
  final String? id;
  final String userId;
  final String tipo;
  final String material;
  final bool reciclable;
  final String contenedor;
  final double pesoEstimadoKg;
  final double co2AhorradoKg;
  final double? confianza;
  final String? fotoUrl;
  final DateTime? createdAt;

  Residuo({
    this.id,
    required this.userId,
    required this.tipo,
    required this.material,
    required this.reciclable,
    required this.contenedor,
    required this.pesoEstimadoKg,
    required this.co2AhorradoKg,
    this.confianza,
    this.fotoUrl,
    this.createdAt,
  });

  // ──────────────────────────────────────────────
  // GET → Deserializar desde JSON de Supabase
  // ──────────────────────────────────────────────
  factory Residuo.fromJson(Map<String, dynamic> json) {
    return Residuo(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      tipo: json['tipo'] as String,
      material: json['material'] as String,
      reciclable: json['reciclable'] as bool,
      contenedor: json['contenedor'] as String,
      pesoEstimadoKg: (json['peso_estimado_kg'] as num).toDouble(),
      co2AhorradoKg: (json['co2_ahorrado_kg'] as num).toDouble(),
      confianza: (json['confianza'] as num?)?.toDouble(),
      fotoUrl: json['foto_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // ──────────────────────────────────────────────
  // POST → Serializar a JSON para Supabase
  // ──────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'tipo': tipo,
      'material': material,
      'reciclable': reciclable,
      'contenedor': contenedor,
      'peso_estimado_kg': pesoEstimadoKg,
      'co2_ahorrado_kg': co2AhorradoKg,
      if (confianza != null) 'confianza': confianza,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }
}
