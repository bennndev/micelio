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

            // Barra superior (Top Bar)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.pop(context),
                    child: Icon(PhosphorIconsRegular.x, color: Colors.white),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Encuadra el residuo y toma la foto',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: () => _takePhoto(ImageSource.gallery),
                    child: Icon(PhosphorIconsRegular.image, color: Colors.white),
                  ),
                ],
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
