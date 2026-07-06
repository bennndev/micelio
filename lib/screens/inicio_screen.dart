import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Datos Mock
  final String userName = "Micelio";
  final double kgReciclados = 12.5;
  final int racha = 7;
  final int retoActual = 4;
  final int retoTotal = 6;

  final List<Map<String, dynamic>> actividadReciente = [
    {
      'nombre': 'Botella de Plástico',
      'fecha': 'Hace 2 horas',
      'icono': PhosphorIconsFill.drop,
    },
    {
      'nombre': 'Caja de Cartón',
      'fecha': 'Ayer',
      'icono': PhosphorIconsFill.package,
    },
    {
      'nombre': 'Lata de Aluminio',
      'fecha': 'Hace 2 días',
      'icono': PhosphorIconsFill.cylinder,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return FScaffold(
      header: FHeader(
        title: Text('Hola, $userName', style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold)),
        suffixes: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/perfil'),
            child: FAvatar(
              image: const AssetImage('assets/images/icon.png'),
              fallback: const Text('MC'),
              size: 40,
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            _buildHeroCard(theme),
            const SizedBox(height: 24),
            
            // Reto Semanal
            _buildRetoSemanal(theme),
            const SizedBox(height: 32),
            
            // Botón Escanear
            FButton(
              onPress: () => Navigator.pushNamed(context, '/escanear'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIconsFill.scan, color: theme.colors.primaryForeground),
                  const SizedBox(width: 8),
                  Text('Escanear residuo', style: theme.typography.md.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Actividad Reciente
            _buildActividadReciente(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(FThemeData theme) {
    return FCard(
      title: Text('Tu Impacto', style: theme.typography.md.copyWith(fontWeight: FontWeight.bold)),
      subtitle: const Text('Resumen de tu actividad en la red miceliar.'),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(theme, '$kgReciclados', 'kg Reciclados'),
              Container(width: 1, height: 40, color: theme.colors.border),
              // Racha bioluminiscente
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: AppTheme.bioluminescentGlow(),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIconsFill.flame, color: theme.colors.primary, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$racha',
                            style: AppTheme.statsStyle(
                              context: context,
                              baseStyle: theme.typography.xl2.copyWith(color: theme.colors.foreground),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Días',
                        style: theme.typography.xs3.copyWith(
                          color: theme.colors.foreground.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetoSemanal(FThemeData theme) {
    double progress = retoActual / retoTotal;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reto Semanal',
          style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FCard(
          title: Text('$retoActual/$retoTotal completado', style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold)),
          subtitle: const Text('Escanea 6 envases esta semana'),
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: FDeterminateProgress(value: progress),
          ),
        ),
      ],
    );
  }

  Widget _buildActividadReciente(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad reciente',
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/historial'),
              child: Text(
                'Ver todo',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...actividadReciente.map((actividad) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(actividad['icono'], color: theme.colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(actividad['nombre'], style: theme.typography.sm.copyWith(fontWeight: FontWeight.w500)),
                        Text(actividad['fecha'], style: theme.typography.xs.copyWith(color: theme.colors.foreground.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem(FThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.statsStyle(
            context: context,
            baseStyle: theme.typography.xl2.copyWith(color: theme.colors.foreground),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.typography.xs3.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colors.foreground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
