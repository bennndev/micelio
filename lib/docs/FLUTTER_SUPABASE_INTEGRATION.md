# Integración Flutter + Supabase — Micelio Digital

> **Versión:** 1.0
> **Propósito:** Guía paso a paso para conectar la app Flutter con Supabase, usando todo lo que ya configuramos en el backend.
> **Pre-requisito:** Supabase ya configurado según `supabase-setup-guide.md`

---

## 📋 Índice

1. [Crear proyecto Flutter](#1-crear-proyecto-flutter)
2. [Dependencias](#2-dependencias)
3. [Configurar Supabase en Flutter](#3-configurar-supabase-en-flutter)
4. [Modelos de datos](#4-modelos-de-datos)
5. [Auth: Registro e inicio de sesión](#5-auth-registro-e-inicio-de-sesión)
6. [Repositorio de Residuos](#6-repositorio-de-residuos)
7. [Repositorio de Estadísticas y Logros](#7-repositorio-de-estadísticas-y-logros)
8. [Storage: subir fotos de residuos](#8-storage-subir-fotos-de-residuos)
9. [Probar la conexión](#9-probar-la-conexión)
10. [Manejo de errores comunes](#10-manejo-de-errores-comunes)

---

## 1. Crear proyecto Flutter

```bash
flutter create --org com.micelio micelio_digital
cd micelio_digital
```

Estructura final de carpetas que vamos a tener:

```
lib/
├── main.dart
├── data/
│   ├── supabase/
│   │   └── supabase_client.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── residuo_repository.dart
│       ├── estadisticas_repository.dart
│       └── storage_repository.dart
├── domain/
│   └── models/
│       ├── residuo.dart
│       ├── estadisticas.dart
│       ├── logro.dart
│       └── material.dart
└── presentation/
    └── providers/
        └── supabase_providers.dart
```

---

## 2. Dependencias

Editar `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.8.0

  # Riverpod para inyección de dependencias
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Riverpod generación de código
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.12
```

Ejecutar:

```bash
flutter pub get
```

---

## 3. Configurar Supabase en Flutter

### 3.1. Crear el cliente Supabase

```dart
// lib/data/supabase/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class MicelioSupabase {
  // ⚠️ REEMPLAZÁ con los valores de TU proyecto Supabase
  // Los encontrás en: Project Settings → API
  static const String _supabaseUrl = 'https://xxxxxxxxxxxx.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIs...';

  static final SupabaseClient client = Supabase.instance.client;

  /// Inicializar Supabase. LLAMAR ANTES DE runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }
}
```

> **⚠️ Dónde conseguir las credenciales:**
> 1. Supabase Dashboard → **Project Settings** → **API**
> 2. Copiá **`Project URL`** y **`anon public key`**
> 3. Pegalos en `_supabaseUrl` y `_supabaseAnonKey`
>
> **NUNCA** compartas ni subas a git la `service_role_key`. Solo se usa la `anon key` porque las RLS policies protegen los datos.

### 3.2. Inicializar en main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'data/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase ANTES que cualquier cosa
  await MicelioSupabase.initialize();

  runApp(const MicelioDigitalApp());
}

class MicelioDigitalApp extends StatelessWidget {
  const MicelioDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micelio Digital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(), // ← lo creamos después
    );
  }
}
```

### 3.3. Usar el cliente desde cualquier parte

```dart
final supabase = MicelioSupabase.client;
// o directamente:
final supabase = Supabase.instance.client;
```

Ambos son equivalentes.

---

## 4. Modelos de datos

Cada modelo tiene `fromJson` (para leer de Supabase) y `toJson` (para escribir en Supabase).

### 4.1. Residuo

```dart
// lib/domain/models/residuo.dart

class Residuo {
  final String? id;
  final String userId;
  final String tipo;           // ej: "Botella de agua"
  final String material;       // plástico, vidrio, papel, orgánico, metal
  final bool reciclable;
  final String contenedor;     // Azul, Amarillo, Verde, Rojo, Marrón
  final double pesoEstimadoKg;
  final double co2AhorradoKg;
  final double? confianza;     // 0.00 a 1.00 (Gemini Vision)
  final String? fotoUrl;
  final DateTime? createdAt;

  Residuo({
    this.id,
    required this.userId,
    required this.tipo,
    required this.material,
    required this.reciclable,
    required this.contenedor,
    required this.pesoEstimadoKg,
    required this.co2AhorradoKg,
    this.confianza,
    this.fotoUrl,
    this.createdAt,
  });

  // 🔄 De JSON (lo que devuelve Supabase)
  factory Residuo.fromJson(Map<String, dynamic> json) {
    return Residuo(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      tipo: json['tipo'] as String,
      material: json['material'] as String,
      reciclable: json['reciclable'] as bool,
      contenedor: json['contenedor'] as String,
      pesoEstimadoKg: (json['peso_estimado_kg'] as num).toDouble(),
      co2AhorradoKg: (json['co2_ahorrado_kg'] as num).toDouble(),
      confianza: (json['confianza'] as num?)?.toDouble(),
      fotoUrl: json['foto_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // 🔄 A JSON (lo que mandamos a Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'tipo': tipo,
      'material': material,
      'reciclable': reciclable,
      'contenedor': contenedor,
      'peso_estimado_kg': pesoEstimadoKg,
      'co2_ahorrado_kg': co2AhorradoKg,
      if (confianza != null) 'confianza': confianza,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }
}
```

### 4.2. Estadísticas

```dart
// lib/domain/models/estadisticas.dart

class Estadisticas {
  final String userId;
  final int totalEscanes;
  final double totalKgReciclados;
  final double totalCo2AhorradoKg;
  final int rachaMaxima;
  final int semanaEscanes;
  final double semanaKgReciclados;
  final int retoSemanalObjetivo;
  final int retoSemanalProgreso;
  final String? proximoReto;
  final DateTime updatedAt;

  Estadisticas({
    required this.userId,
    required this.totalEscanes,
    required this.totalKgReciclados,
    required this.totalCo2AhorradoKg,
    required this.rachaMaxima,
    required this.semanaEscanes,
    required this.semanaKgReciclados,
    required this.retoSemanalObjetivo,
    required this.retoSemanalProgreso,
    this.proximoReto,
    required this.updatedAt,
  });

  factory Estadisticas.fromJson(Map<String, dynamic> json) {
    return Estadisticas(
      userId: json['user_id'] as String,
      totalEscanes: json['total_escanes'] as int,
      totalKgReciclados: (json['total_kg_reciclados'] as num).toDouble(),
      totalCo2AhorradoKg: (json['total_co2_ahorrado_kg'] as num).toDouble(),
      rachaMaxima: json['racha_maxima'] as int,
      semanaEscanes: json['semana_escanes'] as int,
      semanaKgReciclados: (json['semana_kg_reciclados'] as num).toDouble(),
      retoSemanalObjetivo: json['reto_semanal_objetivo'] as int,
      retoSemanalProgreso: json['reto_semanal_progreso'] as int,
      proximoReto: json['proximo_reto'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
```

### 4.3. Logro

```dart
// lib/domain/models/logro.dart

class Logro {
  final String? id;
  final String userId;
  final String tipoLogro;    // ej: "5_plasticos", "streak_7"
  final String nombre;       // ej: "Plastikill"
  final String descripcion;
  final String? icono;
  final DateTime fechaObtenido;

  Logro({
    this.id,
    required this.userId,
    required this.tipoLogro,
    required this.nombre,
    required this.descripcion,
    this.icono,
    required this.fechaObtenido,
  });

  factory Logro.fromJson(Map<String, dynamic> json) {
    return Logro(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      tipoLogro: json['tipo_logro'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      icono: json['icono'] as String?,
      fechaObtenido: DateTime.parse(json['fecha_obtenido'] as String),
    );
  }
}
```

### 4.4. Enum de Materiales

```dart
// lib/domain/models/material.dart

/// Materiales de residuos con su contenedor asignado y factor de conversión a CO₂.
///
/// Factores (kg CO₂ evitado por kg de material reciclado):
/// - Plástico PET: 3.0 kg
/// - Vidrio: 0.4 kg
/// - Papel/Cartón: 1.5 kg
/// - Metal (aluminio): 3.0 kg
/// - Orgánico: 0.0 kg (composta)
enum MaterialResiduo {
  plastico('Plástico', 'Azul', 3.0),
  vidrio('Vidrio', 'Verde', 0.4),
  papel('Papel / Cartón', 'Amarillo', 1.5),
  metal('Metal', 'Amarillo', 3.0),
  organico('Orgánico', 'Marrón', 0.0),
  otro('Otro', 'Gris', 0.5);

  final String displayName;
  final String contenedor;
  final double factorCO2;

  const MaterialResiduo(this.displayName, this.contenedor, this.factorCO2);

  /// Buscar un material desde un string (case-insensitive)
  static MaterialResiduo fromString(String value) {
    return MaterialResiduo.values.firstWhere(
      (m) =>
          m.name.toLowerCase() == value.toLowerCase() ||
          m.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => MaterialResiduo.otro,
    );
  }
}
```

---

## 5. Auth: Registro e inicio de sesión

### 5.1. AuthRepository

```dart
// lib/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  /// Registro con email y contraseña.
  /// El trigger handle_new_user() en Supabase crea automáticamente:
  /// - Perfil en usuarios
  /// - Estadísticas iniciales
  /// - Configuración por defecto
  Future<AuthResponse> registrarse(String email, String password) async {
    return _client.auth.signUp(email: email, password: password);
  }

  /// Inicio de sesión
  Future<Session> iniciarSesion(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session!;
  }

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
  }

  /// Usuario actual (null si no hay sesión)
  User? get usuarioActual => _client.auth.currentUser;

  /// Hay sesión activa?
  bool get estaAutenticado => _client.auth.currentUser != null;

  /// Stream de cambios de autenticación (útil para auth gate)
  Stream<AuthState> get onAuthChange => _client.auth.onAuthStateChange;
}
```

### 5.2. Pantalla de Login (ejemplo)

```dart
// lib/presentation/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authRepo = AuthRepository();
  bool _loading = false;

  Future<void> _iniciarSesion() async {
    setState(() => _loading = true);
    try {
      await _authRepo.iniciarSesion(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      // Si llega acá, la sesión ya está activa
      // El AuthGate redirige automáticamente
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _iniciarSesion,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
```

### 5.3. Auth Gate (redirección automática)

```dart
// lib/presentation/auth/auth_gate.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_screen.dart';
import '../home/home_screen.dart'; // la creás después

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthRepository _authRepo;
  late final StreamSubscription<AuthState> _authSub;
  User? _user;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository();
    _user = _authRepo.usuarioActual;

    // Escuchar cambios en tiempo real
    _authSub = _authRepo.onAuthChange.listen((authState) {
      setState(() {
        _user = authState.session?.user;
      });
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si hay usuario → Home, si no → Login
    return _user != null ? const HomeScreen() : const LoginScreen();
  }
}
```

---

## 6. Repositorio de Residuos

```dart
// lib/data/repositories/residuo_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../../domain/models/residuo.dart';

class ResiduoRepository {
  final SupabaseClient _client;

  ResiduoRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  // ──────────────────────────────────────────────
  // GUARDAR un nuevo escaneo
  // ──────────────────────────────────────────────

  /// Guarda un residuo escaneado.
  /// El trigger on_residuo_inserted en Supabase actualiza automáticamente:
  /// - estadisticas (totales, semana)
  /// - usuarios (streak, puntos)
  /// - logros (si corresponde)
  Future<Residuo> guardar(Residuo residuo) async {
    final response = await _client
        .from('residuos')
        .insert(residuo.toJson())
        .select()
        .single();
    return Residuo.fromJson(response);
  }

  // ──────────────────────────────────────────────
  // HISTORIAL
  // ──────────────────────────────────────────────

  /// Obtiene los últimos [limite] residuos escaneados.
  Future<List<Residuo>> obtenerHistorial({int limite = 20}) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('residuos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limite);
    return (response as List).map((r) => Residuo.fromJson(r)).toList();
  }

  /// Filtra residuos por fecha (sin hora).
  Future<List<Residuo>> obtenerPorFecha(DateTime fecha) async {
    final userId = _client.auth.currentUser!.id;
    final fechaStr =
        '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('residuos')
        .select()
        .eq('user_id', userId)
        .eq('created_at::date', fechaStr)  // ← cast a date en PostgreSQL
        .order('created_at', ascending: false);
    return (response as List).map((r) => Residuo.fromJson(r)).toList();
  }

  // ──────────────────────────────────────────────
  // RESUMEN DEL DÍA (ejemplo de query adicional)
  // ──────────────────────────────────────────────

  /// Devuelve el total de kg reciclados hoy.
  Future<double> totalKgHoy() async {
    final userId = _client.auth.currentUser!.id;
    final hoy = DateTime.now();
    final hoyStr =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('residuos')
        .select('peso_estimado_kg')
        .eq('user_id', userId)
        .eq('created_at::date', hoyStr);
    final lista = response as List;
    if (lista.isEmpty) return 0.0;
    return lista.fold<double>(
      0.0,
      (sum, r) => sum + (r['peso_estimado_kg'] as num).toDouble(),
    );
  }
}
```

---

## 7. Repositorio de Estadísticas y Logros

```dart
// lib/data/repositories/estadisticas_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../../domain/models/estadisticas.dart';
import '../../domain/models/logro.dart';

class EstadisticasRepository {
  final SupabaseClient _client;

  EstadisticasRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  /// Obtiene las estadísticas del usuario autenticado.
  Future<Estadisticas?> obtener() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('estadisticas')
        .select()
        .eq('user_id', userId)
        .maybeSingle();               // ← returns null si no hay fila
    if (response == null) return null;
    return Estadisticas.fromJson(response);
  }

  /// Obtiene los logros/insignias obtenidos.
  Future<List<Logro>> obtenerLogros() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('logros')
        .select()
        .eq('user_id', userId)
        .order('fecha_obtenido', ascending: false);
    return (response as List).map((l) => Logro.fromJson(l)).toList();
  }
}
```

---

## 8. Storage: subir fotos de residuos

### 8.1. StorageRepository

```dart
// lib/data/repositories/storage_repository.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class StorageRepository {
  final SupabaseClient _client;
  static const String _bucketName = 'residuos-fotos';

  StorageRepository({SupabaseClient? client})
      : _client = client ?? MicelioSupabase.client;

  // ──────────────────────────────────────────────
  // SUBIR foto
  // ──────────────────────────────────────────────

  /// Sube la foto de un residuo al bucket.
  ///
  /// La ruta se estructura como: {auth.uid}/{residuoId}.jpg
  /// La RLS policy en Supabase usa el primer segmento (auth.uid)
  /// para aislar los archivos por usuario.
  Future<String> subirFoto({
    required String residuoId,
    required List<int> bytes,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final path = '$userId/$residuoId.jpg';

    await _client.storage.from(_bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return path; // ej: "a1b2c3/abc123.jpg"
  }

  /// Subir desde un archivo (ej: de la cámara o galería)
  Future<String> subirFotoDesdeArchivo({
    required String residuoId,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    return subirFoto(residuoId: residuoId, bytes: bytes);
  }

  // ──────────────────────────────────────────────
  // LEER (URL firmada)
  // ──────────────────────────────────────────────

  /// Obtiene una URL firmada para leer la foto (expira en [expiraEnSegundos]).
  Future<String> obtenerUrlFirmada(
    String path, {
    int expiraEnSegundos = 3600, // 1 hora
  }) async {
    return _client.storage
        .from(_bucketName)
        .createSignedUrl(path, expiresIn: expiraEnSegundos);
  }

  // ──────────────────────────────────────────────
  // ELIMINAR foto
  // ──────────────────────────────────────────────

  /// Elimina una foto del bucket.
  Future<void> eliminarFoto(String path) async {
    await _client.storage.from(_bucketName).remove([path]);
  }
}
```

### 8.2. Flujo completo: escanear + subir foto

```dart
// Ejemplo de cómo se usa desde un ViewModel / Provider
// (asumiendo que tenés una imagen capturada)

Future<void> procesarEscaneo({
  required File foto,
  required String tipo,
  required String material,
  required bool reciclable,
  required String contenedor,
  required double pesoKg,
  required double co2Kg,
  double? confianza,
}) async {
  final residuoRepo = ResiduoRepository();
  final storageRepo = StorageRepository();

  // 1. Primero guardar el residuo en la BD (necesitamos el ID generado)
  final residuo = Residuo(
    userId: Supabase.instance.client.auth.currentUser!.id,
    tipo: tipo,
    material: material,
    reciclable: reciclable,
    contenedor: contenedor,
    pesoEstimadoKg: pesoKg,
    co2AhorradoKg: co2Kg,
    confianza: confianza,
  );

  final residuoCreado = await residuoRepo.guardar(residuo);

  // 2. Subir la foto asociada al residuo
  if (residuoCreado.id != null) {
    final path = await storageRepo.subirFotoDesdeArchivo(
      residuoId: residuoCreado.id!,
      file: foto,
    );

    // 3. Actualizar el residuo con la URL de la foto
    // (opcional, para ver la foto desde el historial)
    await Supabase.instance.client.from('residuos').update({
      'foto_url': path,
    }).eq('id', residuoCreado.id!);
  }
}
```

> **Nota:** en este flujo el trigger `on_residuo_inserted` ya actualizó las estadísticas en el paso 1. No necesitás hacer nada más.

---

## 9. Probar la conexión

### 9.1. Test rápido: Auth

```dart
// CUALQUIER parte de la app, probá esto:

final authRepo = AuthRepository();
try {
  await authRepo.registrarse('test@micelio.com', '123456');
  print('✅ Usuario registrado');
  print('   Auth UID: ${authRepo.usuarioActual?.id}');
  print('   Email:    ${authRepo.usuarioActual?.email}');
} catch (e) {
  print('❌ Error: $e');
}
```

Después de registrarte, verificá en Supabase Dashboard:
1. **Authentication → Users** → debería aparecer el nuevo usuario
2. **Table Editor → usuarios** → debería tener su perfil creado por el trigger
3. **Table Editor → estadisticas** → debería tener su fila (todo en 0)
4. **Table Editor → configuracion_usuario** → debería tener su configuración por defecto

### 9.2. Test rápido: Insertar residuo

```dart
final residuoRepo = ResiduoRepository();
try {
  final residuo = Residuo(
    userId: Supabase.instance.client.auth.currentUser!.id,
    tipo: 'Botella de agua',
    material: 'plástico',
    reciclable: true,
    contenedor: 'Azul',
    pesoEstimadoKg: 0.050,
    co2AhorradoKg: 0.150,
    confianza: 0.95,
  );

  final creado = await residuoRepo.guardar(residuo);
  print('✅ Residuo guardado: ${creado.id}');

  // Verificá que las estadísticas se actualizaron:
  final statsRepo = EstadisticasRepository();
  final stats = await statsRepo.obtener();
  print('📊 Estadísticas: total_escanes=${stats?.totalEscanes}');
} catch (e) {
  print('❌ Error: $e');
}
```

### 9.3. Test rápido: Subir foto

```dart
final storageRepo = StorageRepository();
try {
  final path = await storageRepo.subirFoto(
    residuoId: 'test-001',
    bytes: [0xFF, 0xD8, 0xFF, ...], // bytes de una imagen JPG real
  );
  print('✅ Foto subida: $path');

  final url = await storageRepo.obtenerUrlFirmada(path);
  print('🔗 URL firmada: $url');
} catch (e) {
  print('❌ Error: $e');
}
```

### 9.4. Verificar en Supabase Dashboard

Después de cada test, revisá:

| Qué revisar | Dónde en Supabase |
|-------------|-------------------|
| Usuario creado | **Authentication → Users** |
| Perfil en usuarios | **Table Editor → usuarios** |
| Estadísticas iniciales | **Table Editor → estadisticas** |
| Residuo insertado | **Table Editor → residuos** |
| Logro desbloqueado (si aplica) | **Table Editor → logros** |
| Foto subida | **Storage → residuos-fotos** |
| Registros en logs | **Database → Logs** (si algo falla) |

---

## 10. Manejo de errores comunes

### 10.1. "RLS policy violated" o "permission denied"

**Causa:** la RLS policy bloquea la operación.

**Soluciones:**
- Verificá que el usuario está autenticado: `Supabase.instance.client.auth.currentUser != null`
- Verificá que estás filtrando por `user_id` o `auth.uid()` en las queries
- En Supabase Dashboard → **Authentication → Policies**, revisá que las policies estén aplicadas

```dart
// ❌ Esto falla si RLS está activo (no filtra por usuario)
await supabase.from('residuos').select();

// ✅ Esto funciona (filtra por usuario autenticado)
await supabase.from('residuos').select().eq('user_id', userId);
```

### 10.2. "Invalid API key"

**Causa:** la `anon key` es incorrecta o el `url` del proyecto está mal.

**Solución:** verificá en **Project Settings → API** que ambos valores coincidan exactamente. No uses la `service_role_key`.

### 10.3. "Could not connect to server"

**Causa:** sin internet, o la región del proyecto está caída.

**Solución:**
- Verificá conexión a internet
- Verificá que el proyecto esté activo en Supabase Dashboard
- Para MVP, manejá el error y mostrá un mensaje amigable

### 10.4. "new row violates row-level security policy" al insertar

**Causa:** la RLS policy de INSERT no permite la operación.

**Solución:** 
- Verificá que el `user_id` que estás insertando sea igual a `auth.uid()`
- Si el trigger `handle_new_user` falló, el usuario no tiene fila en `usuarios` → los FKs fallan

```dart
// Siempre usá el ID del usuario autenticado
final userId = supabase.auth.currentUser!.id;
```

### 10.5. Error 409 al registrarse

**Causa:** el email ya existe.

**Solución:** usá otro email, o implementá "olvidé mi contraseña".

### 10.6. El trigger no creó el perfil

Si el usuario se registra pero no aparece en `usuarios`:
1. Revisá que el trigger `on_auth_user_created` existe en Supabase
2. Revisá los logs en **Database → Logs** para ver errores del trigger
3. Ejecutá esto en el SQL Editor:

```sql
SELECT tgname, tgrelid::regclass
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';
```

---

## Resumen del flujo completo

```
Usuario abre la app
      │
      ▼
AuthGate verifica sesión
      │
      ├─ No hay sesión → LoginScreen
      │                     │
      │                     ▼
      │               AuthRepository.registrarse()
      │               AuthRepository.iniciarSesion()
      │                     │
      │                     ▼ (trigger handle_new_user)
      │               Supabase crea: usuarios + estadisticas + config
      │
      ├─ Hay sesión → HomeScreen
      │                  │
      │                  ▼
      │            Usuario escanea residuo
      │                  │
      │                  ├─ 1. Subir foto → StorageRepository.subirFoto()
      │                  ├─ 2. Guardar en BD → ResiduoRepository.guardar()
      │                  │        │
      │                  │        ▼ (trigger on_residuo_inserted)
      │                  │  Supabase actualiza: stats + streak + puntos
      │                  │
      │                  └─ 3. Mostrar resultado + consejo
      │
      ▼
EstadisticasRepository.obtener() → Dashboard con gráficos
LogrosRepository.obtenerLogros() → Pantalla de logros/insignias
```

---

## Archivos creados (resumen)

```
lib/
├── main.dart
├── data/
│   ├── supabase/
│   │   └── supabase_client.dart       ← MicelioSupabase (singleton)
│   └── repositories/
│       ├── auth_repository.dart        ← Registro, login, logout, stream
│       ├── residuo_repository.dart     ← CRUD de escaneos
│       ├── estadisticas_repository.dart ← Stats + logros
│       └── storage_repository.dart     ← Fotos en bucket
├── domain/
│   └── models/
│       ├── residuo.dart
│       ├── estadisticas.dart
│       ├── logro.dart
│       └── material.dart               ← Enum con contenedores y factores CO₂
└── presentation/
    ├── auth/
    │   ├── auth_gate.dart              ← Redirección login/home
    │   └── login_screen.dart           ← Pantalla de login
    └── providers/
        └── supabase_providers.dart     ← Riverpod providers
```

---

**Fin de la guía.** Tu causa ya tiene todo para conectar Flutter con Supabase y empezar a escanear residuos 🌱
