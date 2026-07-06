import 'package:flutter/foundation.dart';
import '../../data/repositories/residuo_repository.dart';
import '../../domain/models/residuo.dart';

class HistorialViewModel extends ChangeNotifier {
  final ResiduoRepository _residuoRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Residuo> _residuos = [];
  String _filtroActivo = 'Todos';

  final List<String> filtros = ['Todos', 'Plástico', 'Papel', 'Vidrio', 'Orgánico'];

  HistorialViewModel({ResiduoRepository? residuoRepository})
      : _residuoRepository = residuoRepository ?? ResiduoRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Residuo> get residuos => _residuos;
  String get filtroActivo => _filtroActivo;

  /// Devuelve el peso acumulado por cada día de la semana actual (Lunes a Domingo)
  List<double> get pesosPorDia {
    final ahora = DateTime.now();
    // Encontrar el lunes de esta semana
    final lunesEstaSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final inicioLunes = DateTime(lunesEstaSemana.year, lunesEstaSemana.month, lunesEstaSemana.day);

    final lista = List<double>.filled(7, 0.0);

    for (final r in _residuos) {
      if (r.createdAt == null) continue;
      
      // Calcular la diferencia en días desde el lunes
      final diff = r.createdAt!.difference(inicioLunes).inDays;
      if (diff >= 0 && diff < 7) {
        final diaSemana = r.createdAt!.weekday - 1; // 0 para lunes, 6 para domingo
        lista[diaSemana] += r.pesoEstimadoKg;
      }
    }
    return lista;
  }

  // ──────────────────────────────────────────────
  // GET → Filtrar residuos cargados
  // ──────────────────────────────────────────────
  List<Residuo> get residuosFiltrados {
    if (_filtroActivo == 'Todos') {
      return _residuos;
    }
    return _residuos.where((r) {
      final material = r.material.toLowerCase();
      final filtro = _filtroActivo.toLowerCase();
      // Mapear filtros a coincidencias semánticas
      if (filtro == 'papel') {
        return material.contains('papel') || material.contains('cartón');
      }
      return material.contains(filtro);
    }).toList();
  }

  // ──────────────────────────────────────────────
  // HANDLE → Cambiar el filtro activo
  // ──────────────────────────────────────────────
  void setFiltro(String filtro) {
    if (filtros.contains(filtro) && _filtroActivo != filtro) {
      _filtroActivo = filtro;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // GET → Cargar el historial desde el repositorio
  // ──────────────────────────────────────────────
  Future<void> cargarHistorial() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _residuos = await _residuoRepository.obtenerHistorial();
    } catch (e) {
      _errorMessage = 'No se pudo cargar tu historial de reciclaje.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
