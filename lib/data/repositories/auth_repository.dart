import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  // ──────────────────────────────────────────────
  // POST → Registro con email, contraseña y nombre completo
  // ──────────────────────────────────────────────
  Future<AuthResponse> registrarse(String email, String password, {String? nombreCompleto}) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: nombreCompleto != null ? {'nombre_completo': nombreCompleto} : null,
    );
  }

  // ──────────────────────────────────────────────
  // POST → Inicio de sesión con email y contraseña
  // ──────────────────────────────────────────────
  Future<Session> iniciarSesion(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session!;
  }

  // ──────────────────────────────────────────────
  // POST → Inicio de sesión con Google (OAuth)
  // ──────────────────────────────────────────────
  Future<void> iniciarSesionConGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.micelio://login-callback/',
    );
  }

  // ──────────────────────────────────────────────
  // POST → Cerrar sesión
  // ──────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
  }

  // ──────────────────────────────────────────────
  // GET → Obtener el usuario actual
  // ──────────────────────────────────────────────
  User? get usuarioActual => _client.auth.currentUser;

  // ──────────────────────────────────────────────
  // GET → Verificar si el usuario está autenticado
  // ──────────────────────────────────────────────
  bool get estaAutenticado => _client.auth.currentUser != null;

  // ──────────────────────────────────────────────
  // GET → Stream de cambios en la sesión (Auth Gate)
  // ──────────────────────────────────────────────
  Stream<AuthState> get onAuthChange => _client.auth.onAuthStateChange;
}
