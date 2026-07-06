class Estadisticas {
  final String userId;
  final int totalEscanes;
  final double totalKgReciclados;
  final double totalCo2AhorradoKg;
  final int rachaMaxima;
  final int semanaEscanes;
  final double semanaKgReciclados;
  final int retoSemanalObjetivo;
  final int retoSemanalProgreso;
  final String? proximoReto;
  final DateTime updatedAt;

  Estadisticas({
    required this.userId,
    required this.totalEscanes,
    required this.totalKgReciclados,
    required this.totalCo2AhorradoKg,
    required this.rachaMaxima,
    required this.semanaEscanes,
    required this.semanaKgReciclados,
    required this.retoSemanalObjetivo,
    required this.retoSemanalProgreso,
    this.proximoReto,
    required this.updatedAt,
  });

  // ──────────────────────────────────────────────
  // GET → Deserializar estadísticas de Supabase
  // ──────────────────────────────────────────────
  factory Estadisticas.fromJson(Map<String, dynamic> json) {
    return Estadisticas(
      userId: json['user_id'] as String,
      totalEscanes: json['total_escanes'] as int,
      totalKgReciclados: (json['total_kg_reciclados'] as num).toDouble(),
      totalCo2AhorradoKg: (json['total_co2_ahorrado_kg'] as num).toDouble(),
      rachaMaxima: json['racha_maxima'] as int,
      semanaEscanes: json['semana_escanes'] as int,
      semanaKgReciclados: (json['semana_kg_reciclados'] as num).toDouble(),
      retoSemanalObjetivo: json['reto_semanal_objetivo'] as int,
      retoSemanalProgreso: json['reto_semanal_progreso'] as int,
      proximoReto: json['proximo_reto'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
