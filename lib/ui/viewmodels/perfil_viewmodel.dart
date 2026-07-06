import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/estadisticas_repository.dart';
import '../../domain/models/estadisticas.dart';
import '../../domain/models/logro.dart';

class PerfilViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final EstadisticasRepository _estadisticasRepository;

  bool _isLoading = false;
  bool _isSigningOut = false;
  String? _errorMessage;

  Estadisticas? _estadisticas;
  List<Logro> _logrosObtenidos = [];

  PerfilViewModel({
    AuthRepository? authRepository,
    EstadisticasRepository? estadisticasRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _estadisticasRepository = estadisticasRepository ?? EstadisticasRepository();

  bool get isLoading => _isLoading;
  bool get isSigningOut => _isSigningOut;
  String? get errorMessage => _errorMessage;
  Estadisticas? get estadisticas => _estadisticas;

  // ──────────────────────────────────────────────
  // GET → Datos de identidad del usuario
  // ──────────────────────────────────────────────
  String get nombreUsuario {
    final user = _authRepository.usuarioActual;
    if (user == null) return 'Usuario';
    
    final metadata = user.userMetadata;
    if (metadata != null) {
      if (metadata['nombre_completo'] != null && metadata['nombre_completo'].toString().trim().isNotEmpty) {
        return metadata['nombre_completo'];
      }
      if (metadata['full_name'] != null && metadata['full_name'].toString().trim().isNotEmpty) {
        return metadata['full_name'];
      }
    }
    
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }
    
    return 'Usuario';
  }

  String get iniciales {
    final nombre = nombreUsuario;
    if (nombre == 'Usuario') return 'US';
    final parts = nombre.split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, 1).toUpperCase();
  }

  String? get avatarUrl {
    final user = _authRepository.usuarioActual;
    final url = user?.userMetadata?['avatar_url'];
    return (url != null && url.toString().isNotEmpty) ? url.toString() : null;
  }

  // Atributos de impacto acumulado
  double get kgTotal => _estadisticas?.totalKgReciclados ?? 0.0;
  double get co2Evitado => _estadisticas?.totalCo2AhorradoKg ?? 0.0;
  int get maxRacha => _estadisticas?.rachaMaxima ?? 0;

  // Cálculos de gamificación
  String get userLevel {
    if (kgTotal >= 100) return 'Guardián del Bosque';
    if (kgTotal >= 50) return 'Héroe del Micelio';
    if (kgTotal >= 10) return 'Recolector Activo';
    return 'Recolector Novato';
  }

  String get proximoNivel {
    if (kgTotal >= 100) return 'Guardián del Bosque';
    if (kgTotal >= 50) return 'Guardián del Bosque';
    if (kgTotal >= 10) return 'Héroe del Micelio';
    return 'Recolector Activo';
  }

  double get progressToNextLevel {
    if (kgTotal >= 100) return 1.0;
    // Nivel 0 a 10 kg
    if (kgTotal < 10) return kgTotal / 10.0;
    // Nivel 10 a 50 kg
    if (kgTotal < 50) return (kgTotal - 10) / 40.0;
    // Nivel 50 a 100 kg
    return (kgTotal - 50) / 50.0;
  }

  String get puntosFaltantesString {
    if (kgTotal >= 100) return 'Nivel máximo alcanzado';
    double proximoHito = 10.0;
    if (kgTotal >= 50) {
      proximoHito = 100.0;
    } else if (kgTotal >= 10) {
      proximoHito = 50.0;
    }
    final faltante = proximoHito - kgTotal;
    return 'Faltan ${faltante.toStringAsFixed(1)} kg para el siguiente nivel';
  }

  // Lista de insignias combinada con las obtenidas de Supabase
  List<Map<String, dynamic>> get insignias {
    final hasPrimerEscaneo = _logrosObtenidos.any((l) => l.tipoLogro == 'primer_escaneo');
    final hasExpertoVidrio = _logrosObtenidos.any((l) => l.tipoLogro == '10_vidrios');
    final hasRacha7 = _logrosObtenidos.any((l) => l.tipoLogro == 'streak_7');
    final hasGuardian = kgTotal >= 100;

    return [
      {
        'titulo': 'Primer Escaneo',
        'key': 'primer_escaneo',
        'obtenido': hasPrimerEscaneo,
        'desc': 'Escaneaste tu primer residuo exitosamente.'
      },
      {
        'titulo': 'Experto en Vidrio',
        'key': 'experto_vidrio',
        'obtenido': hasExpertoVidrio,
        'desc': 'Has reciclado más de 10 envases de vidrio.'
      },
      {
        'titulo': 'Racha 7 Días',
        'key': 'racha_7',
        'obtenido': hasRacha7,
        'desc': 'Mantuviste una racha de reciclaje por una semana entera.'
      },
      {
        'titulo': 'Guardián del Bosque',
        'key': 'guardian_bosque',
        'obtenido': hasGuardian,
        'desc': 'Recicla 100 kg en total para desbloquear.'
      },
    ];
  }

  // ──────────────────────────────────────────────
  // GET → Cargar estadísticas y logros del usuario
  // ──────────────────────────────────────────────
  Future<void> cargarPerfil() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _estadisticasRepository.obtener();
      final logros = await _estadisticasRepository.obtenerLogros();

      _estadisticas = stats;
      _logrosObtenidos = logros;
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los datos de perfil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // POST → Cerrar la sesión activa
  // ──────────────────────────────────────────────
  Future<bool> logout() async {
    _isSigningOut = true;
    notifyListeners();

    try {
      await _authRepository.cerrarSesion();
      _isSigningOut = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSigningOut = false;
      _errorMessage = 'Error al cerrar sesión.';
      notifyListeners();
      return false;
    }
  }
}
