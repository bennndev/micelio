import 'package:supabase_flutter/supabase_flutter.dart';

class MicelioSupabase {
  static const String _url = 'https://dtugytvcqvvozmiaunpz.supabase.co';
  static const String _anonKey = 'sb_publishable_wLymKr680bHZQVcFO6Kf8g_pMYurtRe';

  // ──────────────────────────────────────────────
  // GET → Retorna el cliente único de Supabase
  // ──────────────────────────────────────────────
  static SupabaseClient get client => Supabase.instance.client;

  // ──────────────────────────────────────────────
  // INIT → Inicializar cliente de Supabase
  //       Llamar antes de runApp() en main()
  // ──────────────────────────────────────────────
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      publishableKey: _anonKey,
    );
  }
}
