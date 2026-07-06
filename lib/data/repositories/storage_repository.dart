import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class StorageRepository {
  final SupabaseClient _client;
  static const String _bucketName = 'residuos-fotos';

  StorageRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  // ──────────────────────────────────────────────
  // POST → Subir los bytes de una foto
  // ──────────────────────────────────────────────
  Future<String> subirFoto({
    required String residuoId,
    required Uint8List bytes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final path = '${user.id}/$residuoId.jpg';

    await _client.storage.from(_bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return path;
  }

  // ──────────────────────────────────────────────
  // POST → Subir foto desde un archivo File
  // ──────────────────────────────────────────────
  Future<String> subirFotoDesdeArchivo({
    required String residuoId,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    return subirFoto(residuoId: residuoId, bytes: bytes);
  }

  // ──────────────────────────────────────────────
  // GET → Obtener URL firmada para visualización
  // ──────────────────────────────────────────────
  Future<String> obtenerUrlFirmada(
    String path, {
    int expiraEnSegundos = 3600,
  }) async {
    return _client.storage
        .from(_bucketName)
        .createSignedUrl(path, expiraEnSegundos);
  }

  // ──────────────────────────────────────────────
  // DELETE → Eliminar foto del storage
  // ──────────────────────────────────────────────
  Future<void> eliminarFoto(String path) async {
    await _client.storage.from(_bucketName).remove([path]);
  }
}
