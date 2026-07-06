import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Datos del usuario (Dinámicos)
  String get _nombreUsuario {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 'Usuario';
    
    final metadata = user.userMetadata;
    if (metadata != null) {
      if (metadata['nombre_completo'] != null && metadata['nombre_completo'].toString().trim().isNotEmpty) {
        return metadata['nombre_completo'];
      }
      if (metadata['full_name'] != null && metadata['full_name'].toString().trim().isNotEmpty) {
        return metadata['full_name'];
      }
    }
    
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }
    
    return 'Usuario';
  }

  String get _iniciales {
    final nombre = _nombreUsuario;
    if (nombre == 'Usuario') return 'US';
    final parts = nombre.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, 1).toUpperCase();
  }

  String? get _avatarUrl {
    final user = Supabase.instance.client.auth.currentUser;
    final url = user?.userMetadata?['avatar_url'];
    return (url != null && url.toString().isNotEmpty) ? url.toString() : null;
  }

  // Mock data (Impacto y Stats)
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
        title: Text('Hola, $_nombreUsuario', style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold)),
        suffixes: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/perfil'),
            child: _avatarUrl != null
                ? FAvatar(
                    image: NetworkImage(_avatarUrl!) as ImageProvider<Object>,
                    size: 40,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colors.primary,
                    ),
                    child: Center(
                      child: Text(
                        _iniciales, 
                        style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold, color: theme.colors.primaryForeground)
                      )
                    ),
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
