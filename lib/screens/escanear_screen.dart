import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EscanearScreen extends StatefulWidget {
  const EscanearScreen({super.key});

  @override
  State<EscanearScreen> createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (mounted) {
          // Navega a la pantalla de procesando pasando la imagen
          Navigator.pushReplacementNamed(context, '/procesando', arguments: image.path);
        }
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro para simular viewfinder
      body: SafeArea(
        child: Stack(
          children: [
            // Simulación de feed de cámara a pantalla completa
            Positioned.fill(
              child: Center(
                child: Icon(
                  PhosphorIconsDuotone.camera,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            
            // Overlay de guía visual (esquinas de encuadre)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colors.primary, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Esquinas iluminadas simuladas (glow)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Barra superior (Top Bar - Pill)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.scan,
                      size: 28,
                      color: theme.colors.foreground,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Encuadra el residuo',
                            style: theme.typography.md.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colors.foreground,
                            ),
                          ),
                          Text(
                            'y toma la foto',
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.foreground.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        PhosphorIconsRegular.x,
                        size: 24,
                        color: theme.colors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controles inferiores (Bottom Controls)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FButton.icon(
                  variant: FButtonVariant.primary,
                  onPress: () => _takePhoto(ImageSource.camera),
                  // Botón grande circular

                  child: Icon(PhosphorIconsFill.camera, size: 32, color: theme.colors.primaryForeground),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
