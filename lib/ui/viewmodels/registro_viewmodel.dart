import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';

class RegistroViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  RegistroViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ──────────────────────────────────────────────
  // POST → Registrar un nuevo usuario en la app
  // ──────────────────────────────────────────────
  Future<AuthResponse?> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final res = await _authRepository.registrarse(
        email,
        password,
        nombreCompleto: nombre,
      );

      if (res.session == null) {
        _successMessage = 'Revisa tu bandeja de entrada para confirmar tu correo.';
      }

      _isLoading = false;
      notifyListeners();
      return res;
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        _errorMessage = 'Este correo ya está registrado.';
      } else {
        _errorMessage = e.message;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado al registrarte.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
