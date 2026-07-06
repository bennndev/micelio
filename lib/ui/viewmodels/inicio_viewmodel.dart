import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/estadisticas_repository.dart';
import '../../data/repositories/residuo_repository.dart';
import '../../domain/models/estadisticas.dart';
import '../../domain/models/residuo.dart';

class InicioViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final EstadisticasRepository _estadisticasRepository;
  final ResiduoRepository _residuoRepository;

  bool _isLoading = false;
  String? _errorMessage;

  Estadisticas? _estadisticas;
  List<Residuo> _actividadReciente = [];

  InicioViewModel({
    AuthRepository? authRepository,
    EstadisticasRepository? estadisticasRepository,
    ResiduoRepository? residuoRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _estadisticasRepository = estadisticasRepository ?? EstadisticasRepository(),
        _residuoRepository = residuoRepository ?? ResiduoRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Estadisticas? get estadisticas => _estadisticas;
  List<Residuo> get actividadReciente => _actividadReciente;

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

  // Fallbacks de datos de impacto (Mocks requeridos si no hay datos reales en la BD)
  double get kgReciclados => _estadisticas?.totalKgReciclados ?? 12.5;
  int get racha => _estadisticas?.rachaMaxima ?? 7;
  int get retoActual => _estadisticas?.retoSemanalProgreso ?? 4;
  int get retoTotal => _estadisticas?.retoSemanalObjetivo ?? 6;

  // ──────────────────────────────────────────────
  // GET → Cargar datos de estadísticas e historial
  // ──────────────────────────────────────────────
  Future<void> cargarDatos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _estadisticasRepository.obtener();
      final historial = await _residuoRepository.obtenerHistorial(limite: 3);

      _estadisticas = stats;
      _actividadReciente = historial;
    } catch (e) {
      _errorMessage = 'Error al cargar los datos del impacto.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
