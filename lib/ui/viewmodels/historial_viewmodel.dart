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
