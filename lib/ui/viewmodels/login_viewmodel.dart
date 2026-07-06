import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ──────────────────────────────────────────────
  // POST → Iniciar sesión con email y contraseña
  // ──────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.iniciarSesion(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        _errorMessage = 'Credenciales incorrectas. Verifica tu email y contraseña.';
      } else {
        _errorMessage = e.message;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado. Intenta de nuevo.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // POST → Iniciar sesión usando Google OAuth
  // ──────────────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.iniciarSesionConGoogle();
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo iniciar sesión con Google.';
      notifyListeners();
      return false;
    }
  }
}
