import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../../domain/models/residuo.dart';

class ResiduoRepository {
  final SupabaseClient _client;

  ResiduoRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  // ──────────────────────────────────────────────
  // POST → Guardar un residuo escaneado
  // ──────────────────────────────────────────────
  Future<Residuo> guardar(Residuo residuo) async {
    final response = await _client
        .from('residuos')
        .insert(residuo.toJson())
        .select()
        .single();
    return Residuo.fromJson(response);
  }

  // ──────────────────────────────────────────────
  // GET → Obtener historial de residuos del usuario
  // ──────────────────────────────────────────────
  Future<List<Residuo>> obtenerHistorial({int limite = 20}) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    
    final response = await _client
        .from('residuos')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limite);
    return (response as List).map((r) => Residuo.fromJson(r)).toList();
  }

  // ──────────────────────────────────────────────
  // GET → Obtener residuos por fecha específica
  // ──────────────────────────────────────────────
  Future<List<Residuo>> obtenerPorFecha(DateTime fecha) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final fechaStr =
        '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('residuos')
        .select()
        .eq('user_id', user.id)
        .eq('created_at::date', fechaStr)
        .order('created_at', ascending: false);
    return (response as List).map((r) => Residuo.fromJson(r)).toList();
  }

  // ──────────────────────────────────────────────
  // GET → Calcular el total de kg reciclados hoy
  // ──────────────────────────────────────────────
  Future<double> totalKgHoy() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0.0;

    final hoy = DateTime.now();
    final hoyStr =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('residuos')
        .select('peso_estimado_kg')
        .eq('user_id', user.id)
        .eq('created_at::date', hoyStr);
    
    final lista = response as List;
    if (lista.isEmpty) return 0.0;
    return lista.fold<double>(
      0.0,
      (sum, r) => sum + (r['peso_estimado_kg'] as num).toDouble(),
    );
  }
}
