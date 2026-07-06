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
    if (response == null) return null;
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
