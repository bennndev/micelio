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
      // 1. Simular el delay de la llamada a Gemini Vision
      await Future.delayed(const Duration(seconds: 2));

      final File imageFile = File(imagePath);
      // Usar un timestamp como ID provisorio del residuo para el nombre de la foto
      final String tempResiduoId = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Subir imagen a Supabase Storage
      final String storagePath = await _storageRepository.subirFotoDesdeArchivo(
        residuoId: tempResiduoId,
        file: imageFile,
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado.');

      // 3. Clasificar (Mock de IA) e Insertar en Base de Datos
      final nuevoResiduo = Residuo(
        userId: user.id,
        tipo: 'Botella de Plástico PET',
        material: 'Plástico',
        reciclable: true,
        contenedor: 'Amarillo',
        pesoEstimadoKg: 0.05,
        co2AhorradoKg: 0.15,
        confianza: 0.98,
        fotoUrl: storagePath,
      );

      final residuoGuardado = await _residuoRepository.guardar(nuevoResiduo);

      // 4. Obtener URL firmada para la foto
      final String urlFirmada = await _storageRepository.obtenerUrlFirmada(storagePath, expiraEnSegundos: 3600);

      // 5. Preparar datos para ResultadoScreen
      _resultado = {
        "nombre": residuoGuardado.tipo,
        "material": residuoGuardado.material,
        "reciclable": residuoGuardado.reciclable,
        "puntos": 15,
        "confianza": ((residuoGuardado.confianza ?? 0.0) * 100.0).toInt(),
        "instrucciones": "Vacía el contenido, enjuaga brevemente y aplasta la botella antes de depositarla en el contenedor ${residuoGuardado.contenedor}.",
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
      _errorMessage = 'Ocurrió un error inesperado al procesar el residuo.';
    }

    // En caso de error
    _isProcessing = false;
    notifyListeners();
    return null;
  }
}
