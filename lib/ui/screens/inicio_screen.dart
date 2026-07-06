import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../viewmodels/inicio_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../domain/models/residuo.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _viewModel = InicioViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.cargarDatos();
  }

  // ──────────────────────────────────────────────
  // CALC → Obtener el icono adecuado para un residuo
  // ──────────────────────────────────────────────
  IconData _getIconForResiduo(Residuo residuo) {
    switch (residuo.material.toLowerCase()) {
      case 'plástico':
        return PhosphorIconsFill.drop;
      case 'papel':
      case 'cartón':
        return PhosphorIconsFill.package;
      case 'vidrio':
        return PhosphorIconsFill.wine;
      case 'metal':
        return PhosphorIconsFill.cylinder;
      case 'orgánico':
        return PhosphorIconsFill.leaf;
      default:
        return PhosphorIconsFill.trash;
    }
  }

  // ──────────────────────────────────────────────
  // CALC → Formatear la fecha del residuo de forma legible
  // ──────────────────────────────────────────────
  String _formatFecha(DateTime? date) {
    if (date == null) return 'Hace momentos';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return FScaffold(
          header: FHeader(
            title: Text(
              'Hola, ${_viewModel.nombreUsuario}', 
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold)
            ),
            suffixes: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/perfil'),
                child: _viewModel.avatarUrl != null
                    ? FAvatar(
                        image: NetworkImage(_viewModel.avatarUrl!) as ImageProvider<Object>,
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
                            _viewModel.iniciales, 
                            style: theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold, 
                              color: theme.colors.primaryForeground
                            )
                          )
                        ),
                      ),
              ),
            ],
          ),
          child: _viewModel.isLoading
              ? Center(child: FCircularProgress())
              : RefreshIndicator(
                  onRefresh: _viewModel.cargarDatos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Card de impacto
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
                ),
        );
      },
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
              _buildStatItem(theme, '${_viewModel.kgReciclados}', 'kg Reciclados'),
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
                            '${_viewModel.racha}',
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
    double progress = _viewModel.retoTotal > 0 
        ? (_viewModel.retoActual / _viewModel.retoTotal).clamp(0.0, 1.0) 
        : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reto Semanal',
          style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FCard(
          title: Text('${_viewModel.retoActual}/${_viewModel.retoTotal} completado', style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold)),
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
        if (_viewModel.actividadReciente.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'No has escaneado ningún residuo todavía.',
                style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
              ),
            ),
          )
        else
          ..._viewModel.actividadReciente.map((residuo) {
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
                      child: Icon(_getIconForResiduo(residuo), color: theme.colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(residuo.tipo, style: theme.typography.sm.copyWith(fontWeight: FontWeight.w500)),
                          Text(_formatFecha(residuo.createdAt), style: theme.typography.xs.copyWith(color: theme.colors.foreground.withValues(alpha: 0.6))),
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
