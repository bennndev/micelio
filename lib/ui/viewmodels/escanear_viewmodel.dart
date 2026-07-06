import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/residuo_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../domain/models/residuo.dart';

class EscanearViewModel extends ChangeNotifier {
  final ResiduoRepository _residuoRepository;
  final StorageRepository _storageRepository;

  bool _isProcessing = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic>? _resultado;

  EscanearViewModel({
    ResiduoRepository? residuoRepository,
    StorageRepository? storageRepository,
  })  : _residuoRepository = residuoRepository ?? ResiduoRepository(),
        _storageRepository = storageRepository ?? StorageRepository();

  bool get isProcessing => _isProcessing;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get resultado => _resultado;

  /// ---
  /// name: qubit-billing-comment
  /// description: Procesa la foto capturada, la sube al bucket de Supabase,
  /// guarda la clasificación en la DB y obtiene la URL firmada.
  /// author: antigravity
  /// ---
  Future<Map<String, dynamic>?> analizarFoto(String imagePath) async {
    _isProcessing = true;
    _hasError = false;
    _errorMessage = null;
    _resultado = null;
    notifyListeners();

    try {
      // 1. Subir imagen a Supabase Storage
      final File imageFile = File(imagePath);
      final String tempResiduoId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final String storagePath = await _storageRepository.subirFotoDesdeArchivo(
        residuoId: tempResiduoId,
        file: imageFile,
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado.');

      // 2. Obtener URL firmada temporal para que Gemini pueda leer la foto
      final String urlFirmada = await _storageRepository.obtenerUrlFirmada(storagePath, expiraEnSegundos: 3600);

      // 3. Invocar a Gemini Vision a través de la Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'analizar-residuo',
        body: {'imageUrl': urlFirmada},
      );

      final data = response.data as Map<String, dynamic>;

      // 4. Guardar resultado real en la base de datos
      final nuevoResiduo = Residuo(
        userId: user.id,
        tipo: data['tipo'] ?? 'Desconocido',
        material: data['material'] ?? 'Otro',
        reciclable: data['reciclable'] ?? true,
        contenedor: data['contenedor'] ?? 'Gris',
        pesoEstimadoKg: (data['peso_estimado_kg'] as num?)?.toDouble() ?? 0.05,
        co2AhorradoKg: (data['co2_ahorrado_kg'] as num?)?.toDouble() ?? 0.0,
        confianza: (data['confianza'] as num?)?.toDouble() ?? 0.5,
        fotoUrl: storagePath,
      );

      final residuoGuardado = await _residuoRepository.guardar(nuevoResiduo);

      // 5. Preparar datos para ResultadoScreen
      _resultado = {
        "nombre": residuoGuardado.tipo,
        "material": residuoGuardado.material,
        "reciclable": residuoGuardado.reciclable,
        "puntos": (residuoGuardado.reciclable ?? false) ? 15 : 5,
        "confianza": ((residuoGuardado.confianza ?? 0.0) * 100.0).toInt(),
        "instrucciones": data['instrucciones'] ?? "Deposita el residuo en el contenedor ${residuoGuardado.contenedor}.",
        "imagePath": urlFirmada,
      };

      _isProcessing = false;
      notifyListeners();
      return _resultado;
    } on PostgrestException catch (e) {
      _hasError = true;
      _errorMessage = 'Error en DB: ${e.message}';
    } on StorageException catch (e) {
      _hasError = true;
      _errorMessage = 'Error de Storage: ${e.message}';
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error inesperado: $e';
    }

    // En caso de error
    _isProcessing = false;
    notifyListeners();
    return null;
  }
}
