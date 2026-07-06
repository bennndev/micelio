import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EscanearScreen extends StatefulWidget {
  const EscanearScreen({super.key});

  @override
  State<EscanearScreen> createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  
  PermissionStatus _permissionStatus = PermissionStatus.provisional;
  
  final ImagePicker _picker = ImagePicker();
  bool _mostrarConsejo = true;
  
  // Animation for the scan line
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  bool _isCapturing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutSine)
    );

    _checkPermissionAndInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Liberar cámara si pasamos a background
      cameraController.dispose();
      _isCameraInitialized = false;
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      // Re-inicializar cámara al volver a foreground
      _initCamera(cameraController.description);
    }
  }

  Future<void> _checkPermissionAndInit() async {
    final status = await Permission.camera.status;
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      _setupCameras();
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _permissionStatus = status;
    });
    if (status.isGranted) {
      _setupCameras();
    }
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _initCamera(_cameras.first);
      }
    } catch (e) {
      debugPrint('Error obteniendo cámaras: $e');
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    final oldController = _cameraController;
    if (oldController != null) {
      await oldController.dispose();
    }

    final newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraController = newController;

    try {
      await newController.initialize();
      await newController.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isFlashOn = false;
        });
      }
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _cameraController == null) return;
    
    final currentLensDirection = _cameraController!.description.lensDirection;
    CameraDescription newCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection != currentLensDirection,
      orElse: () => _cameras.first,
    );
    
    setState(() {
      _isCameraInitialized = false;
    });
    
    await _initCamera(newCamera);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Error con el flash: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) return;

    try {
      setState(() {
        _isCapturing = true;
      });
      HapticFeedback.mediumImpact();

      final XFile image = await _cameraController!.takePicture();
      
      // Congelar un instante para dar sensación de obturador
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/procesando', arguments: image.path);
      }
    } catch (e) {
      debugPrint('Error al capturar imagen: $e');
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/procesando', arguments: image.path);
        }
      }
    } catch (e) {
      debugPrint('Error al elegir de galería: $e');
    }
  }

  Widget _buildPermissionUI(FThemeData theme) {
    final bool isDenied = _permissionStatus.isDenied || _permissionStatus.isPermanentlyDenied;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsDuotone.camera,
              size: 80,
              color: theme.colors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Acceso a la cámara',
              style: theme.typography.xl3.copyWith(fontWeight: FontWeight.bold, color: theme.colors.foreground),
            ),
            const SizedBox(height: 16),
            Text(
              isDenied 
                  ? 'Has denegado el acceso a la cámara. Por favor, ve a la configuración de tu dispositivo y permite el acceso para poder escanear residuos.' 
                  : 'Necesitamos acceso a tu cámara para que la Inteligencia Artificial pueda escanear y clasificar tus residuos fotográficamente.',
              textAlign: TextAlign.center,
              style: theme.typography.base.copyWith(color: theme.colors.mutedForeground),
            ),
            const SizedBox(height: 32),
            FButton(
              onPress: isDenied ? openAppSettings : _requestPermission,
              child: Text(isDenied ? 'Abrir Configuración' : 'Permitir Acceso'),
            ),
            const SizedBox(height: 16),
            FButton(
              style: FButtonStyle.outline,
              onPress: () => Navigator.pop(context),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    
    // UI de Permisos
    if (!_permissionStatus.isGranted) {
      return Scaffold(
        backgroundColor: theme.colors.background,
        body: SafeArea(child: _buildPermissionUI(theme)),
      );
    }
    
    // UI de Carga
    if (!_isCameraInitialized || _cameraController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: theme.colors.primary)),
      );
    }

    // UI del Escáner
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview a pantalla completa (FittedBox cubre la distorsión)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize?.height ?? 1,
                height: _cameraController!.value.previewSize?.width ?? 1,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),

          // 2. Scrim (oscurecido exterior) y Viewfinder
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScannerOverlayPainter(
                    scanValue: _scanAnimation.value,
                    primaryColor: theme.colors.primary,
                    accentColor: const Color(0xFFDCE775), // Accent glow
                  ),
                );
              },
            ),
          ),

          // 3. Flash momentáneo de obturador
          if (_isCapturing)
            Positioned.fill(
              child: Container(color: Colors.white.withValues(alpha: 0.8)),
            ),

          // 4. Barra Superior (Controles + Consejo)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GlassButton(
                  icon: PhosphorIconsRegular.caretLeft,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _mostrarConsejo 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsDuotone.cornersOut,
                              size: 28,
                              color: theme.colors.foreground,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Encuadra el residuo',
                                    style: theme.typography.sm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colors.foreground,
                                    ),
                                  ),
                                  Text(
                                    'dentro del marco',
                                    style: theme.typography.xs.copyWith(
                                      color: theme.colors.foreground.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _mostrarConsejo = false),
                              child: Icon(
                                PhosphorIconsRegular.x,
                                size: 20,
                                color: theme.colors.foreground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                ),
                const SizedBox(width: 12),
                _GlassButton(
                  icon: _isFlashOn ? PhosphorIconsFill.lightning : PhosphorIconsRegular.lightningSlash,
                  onTap: _toggleFlash,
                ),
              ],
            ),
          ),

          // 5. Controles Inferiores
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            left: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colors.foreground.withValues(alpha: 0.6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón Galería
                        IconButton(
                          onPressed: _pickFromGallery,
                          icon: Icon(PhosphorIconsDuotone.image, color: theme.colors.background, size: 28),
                        ),
                        // Botón Captura Principal
                        GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colors.background, width: 4),
                            ),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: _isCapturing ? 48 : 56,
                                height: _isCapturing ? 48 : 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colors.background,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Botón Cambiar Cámara
                        IconButton(
                          onPressed: _cameras.length > 1 ? _switchCamera : null,
                          icon: Icon(PhosphorIconsDuotone.arrowsClockwise, color: theme.colors.background, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para botones con glassmorphism
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.foreground.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colors.background, size: 24),
          ),
        ),
      ),
    );
  }
}

// Painter para el overlay de escaneo
class _ScannerOverlayPainter extends CustomPainter {
  final double scanValue;
  final Color primaryColor;
  final Color accentColor;

  _ScannerOverlayPainter({
    required this.scanValue,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Definir el tamaño del recuadro
    final double rectWidth = size.width * 0.75;
    final double rectHeight = rectWidth * 1.2;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rectWidth,
      height: rectHeight,
    );
    final RRect rrect = RRect.fromRectAndRadius(scanRect, const Radius.circular(24));

    // 1. Dibujar el Scrim con "hueco"
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawColor(Colors.black.withValues(alpha: 0.5), BlendMode.srcOver);
    final Paint clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(rrect, clearPaint);
    canvas.restore();

    // 2. Dibujar las 4 esquinas del viewfinder
    final Paint cornerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 30.0;
    const double radius = 24.0;
    final double left = scanRect.left;
    final double top = scanRect.top;
    final double right = scanRect.right;
    final double bottom = scanRect.bottom;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(Offset(left + radius, top), radius: const Radius.circular(radius))
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, top)
        ..lineTo(right - radius, top)
        ..arcToPoint(Offset(right, top + radius), radius: const Radius.circular(radius))
        ..lineTo(right, top + cornerLength),
      cornerPaint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLength)
        ..lineTo(left, bottom - radius)
        ..arcToPoint(Offset(left + radius, bottom), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(left + cornerLength, bottom),
      cornerPaint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, bottom)
        ..lineTo(right - radius, bottom)
        ..arcToPoint(Offset(right, bottom - radius), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(right, bottom - cornerLength),
      cornerPaint,
    );

    // 3. Dibujar la línea animada (Scan line) con glow
    final double scanY = (scanRect.top + radius) + (scanRect.height - 2 * radius) * scanValue;
    
    final Paint glowLinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // Glow
      
    final Paint solidLinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(scanRect.left + 10, scanY),
      Offset(scanRect.right - 10, scanY),
      glowLinePaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + 10, scanY),
      Offset(scanRect.right - 10, scanY),
      solidLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanValue != scanValue;
  }
}

