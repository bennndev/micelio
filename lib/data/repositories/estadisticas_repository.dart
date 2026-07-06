import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../../domain/models/estadisticas.dart';
import '../../domain/models/logro.dart';

class EstadisticasRepository {
  final SupabaseClient _client;

  EstadisticasRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  // ──────────────────────────────────────────────
  // GET → Obtener estadísticas del usuario
  // ──────────────────────────────────────────────
  Future<Estadisticas?> obtener() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('estadisticas')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    if (response == null) {
      final nuevoRegistro = {
        'user_id': user.id,
        'total_escanes': 0,
        'total_kg_reciclados': 0.0,
        'total_co2_ahorrado_kg': 0.0,
        'racha_maxima': 0,
        'semana_escanes': 0,
        'semana_kg_reciclados': 0.0,
        'reto_semanal_objetivo': 5,
        'reto_semanal_progreso': 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final insertResponse = await _client
          .from('estadisticas')
          .insert(nuevoRegistro)
          .select()
          .single();
      
      return Estadisticas.fromJson(insertResponse);
    }
    return Estadisticas.fromJson(response);
  }

  // ──────────────────────────────────────────────
  // GET → Obtener la lista de logros del usuario
  // ──────────────────────────────────────────────
  Future<List<Logro>> obtenerLogros() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('logros')
        .select()
        .eq('user_id', user.id)
        .order('fecha_obtenido', ascending: false);
    return (response as List).map((l) => Logro.fromJson(l)).toList();
  }
}
