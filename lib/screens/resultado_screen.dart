import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _irAInicio() {
    Navigator.of(context).pushNamedAndRemoveUntil('/inicio', (route) => false);
  }

  void _escanearOtro() {
    Navigator.of(context).pushReplacementNamed('/escanear');
  }

  Color _getContainerColor(String material) {
    switch (material.toLowerCase()) {
      case 'plástico':
        return Colors.blue;
      case 'papel':
      case 'cartón':
        return Colors.amber;
      case 'vidrio':
        return Colors.green;
      case 'orgánico':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    // Extraer argumentos (JSON + imagePath)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String nombre = args['nombre'] ?? 'Desconocido';
    final String material = args['material'] ?? 'Otro';
    final int puntos = args['puntos'] ?? 0;
    final int confianza = args['confianza'] ?? 98;
    final String? imagePath = args['imagePath'];

    final containerColor = _getContainerColor(material);

    return FScaffold(
      header: FHeader(
        title: const Text('Resultado'),
        suffixes: [
          FButton.icon(
            variant: FButtonVariant.ghost,
            onPress: _irAInicio,
            child: Icon(PhosphorIconsRegular.x, color: theme.colors.foreground),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Celebración + Miniatura
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FadeTransition(
                    opacity: _glowAnimation,
                    child: ScaleTransition(
                      scale: _glowAnimation,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: AppTheme.bioluminescentGlow(),
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colors.secondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colors.primary, width: 2),
                      image: imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imagePath == null
                        ? Icon(PhosphorIconsDuotone.image, size: 40, color: theme.colors.mutedForeground)
                        : null,
                  ),
                  // Badge de Puntos
                  Positioned(
                    bottom: -10,
                    child: FBadge(
                      variant: FBadgeVariant.primary,
                      child: Text('+$puntos Puntos'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Card Principal del Resultado
            FCard(
              title: Text(nombre, style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('Material: $material'),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIconsFill.trash, color: containerColor, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Contenedor recomendado', style: theme.typography.xs),
                              Text(
                                material.toUpperCase(),
                                style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600, color: containerColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      FBadge(
                        variant: FBadgeVariant.secondary,
                        child: Text('$confianza% precisión'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Consejo del Coach
            FCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/images/icon.png', width: 32, height: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consejo del Coach', style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '¡Muy bien! Has reciclado ${args['puntos'] ?? 15} esporas hoy. ${args['instrucciones'] ?? ''}',
                          style: theme.typography.sm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Microreto
            FCard(
              child: Row(
                children: [
                  Icon(PhosphorIconsDuotone.target, color: theme.colors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Microreto Activo', style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold)),
                        Text('Intenta reciclar 2 botellas más esta semana', style: theme.typography.sm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            FButton(
              onPress: _irAInicio,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 12),
            FButton(
              variant: FButtonVariant.outline,
              onPress: _escanearOtro,
              child: const Text('Escanear otro'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
