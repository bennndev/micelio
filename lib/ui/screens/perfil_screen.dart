import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../viewmodels/perfil_viewmodel.dart';
import '../../theme/app_theme.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _viewModel = PerfilViewModel();
  bool _notificacionesActivas = true;

  @override
  void initState() {
    super.initState();
    _viewModel.cargarPerfil();
  }

  // ──────────────────────────────────────────────
  // CALC → Mapear clave de logro a IconData de UI
  // ──────────────────────────────────────────────
  IconData _getIconForInsignia(String key) {
    switch (key) {
      case 'primer_escaneo':
        return PhosphorIconsFill.medal;
      case 'experto_vidrio':
        return PhosphorIconsFill.wine;
      case 'racha_7':
        return PhosphorIconsFill.flame;
      case 'guardian_bosque':
        return PhosphorIconsFill.tree;
      default:
        return PhosphorIconsFill.question;
    }
  }

  // ──────────────────────────────────────────────
  // HANDLE → Mostrar diálogo para confirmar logout
  // ──────────────────────────────────────────────
  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => FDialog(
        title: const Text('Cerrar sesión'),
        body: const Text('¿Seguro que quieres cerrar sesión?'),
        direction: Axis.horizontal,
        actions: [
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FButton(
            variant: FButtonVariant.destructive,
            onPress: () async {
              Navigator.pop(context); // Cierra diálogo
              final ok = await _viewModel.logout();
              if (ok) {
                // El listener global en main.dart detecta la salida y navega
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // HANDLE → Mostrar ventana informativa del logro
  // ──────────────────────────────────────────────
  void _mostrarDetalleLogro(Map<String, dynamic> logro) {
    showDialog(
      context: context,
      builder: (context) => FDialog(
        title: Text(logro['titulo']),
        body: Text(logro['desc']),
        actions: [
          FButton(
            onPress: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return FScaffold(
          header: FHeader(
            title: const Text('Mi Perfil'),
          ),
          child: _viewModel.isLoading
              ? Center(child: FCircularProgress())
              : RefreshIndicator(
                  onRefresh: _viewModel.cargarPerfil,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabecera de Identidad
                        _buildProfileHeader(theme),
                        const SizedBox(height: 32),

                        // Estadísticas Acumuladas
                        Text('Impacto Total', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildStatsRow(theme),
                        const SizedBox(height: 32),

                        // Insignias y Logros
                        Text('Mis Insignias', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildLogrosGrid(theme),
                        const SizedBox(height: 32),

                        // Ajustes de Preferencias
                        Text('Preferencias', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        FCard(
                          child: Column(
                            children: [
                              FSwitch(
                                label: const Text('Notificaciones push'),
                                value: _notificacionesActivas,
                                onChange: (val) => setState(() => _notificacionesActivas = val),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              FButton(
                                variant: FButtonVariant.destructive,
                                onPress: _viewModel.isSigningOut ? null : _cerrarSesion,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_viewModel.isSigningOut)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    else
                                      Icon(PhosphorIconsRegular.signOut, color: theme.colors.destructiveForeground),
                                    const SizedBox(width: 8),
                                    Text(_viewModel.isSigningOut ? 'Cerrando sesión...' : 'Cerrar sesión'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(FThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: AppTheme.bioluminescentGlow(),
            ),
            _viewModel.avatarUrl != null
                ? FAvatar(
                    image: NetworkImage(_viewModel.avatarUrl!) as ImageProvider<Object>,
                    size: 80,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colors.primary,
                    ),
                    child: Center(
                      child: Text(
                        _viewModel.iniciales, 
                        style: theme.typography.xl.copyWith(fontWeight: FontWeight.bold, color: theme.colors.primaryForeground)
                      )
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_viewModel.nombreUsuario, style: theme.typography.xl2.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        FBadge(
          variant: FBadgeVariant.secondary,
          child: Text(_viewModel.userLevel),
        ),
        const SizedBox(height: 24),
        FCard(
          title: Text('Siguiente Nivel: ${_viewModel.proximoNivel}', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(_viewModel.puntosFaltantesString),
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: FDeterminateProgress(value: _viewModel.progressToNextLevel),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(FThemeData theme) {
    return FCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCol(theme, '${_viewModel.kgTotal} kg', 'Reciclados', PhosphorIconsDuotone.recycle),
          Container(width: 1, height: 40, color: theme.colors.border),
          _buildStatCol(theme, '${_viewModel.co2Evitado.toStringAsFixed(1)} kg', 'CO₂ Evitado', PhosphorIconsDuotone.cloud),
          Container(width: 1, height: 40, color: theme.colors.border),
          _buildStatCol(theme, '${_viewModel.maxRacha}', 'Días Racha', PhosphorIconsDuotone.flame),
        ],
      ),
    );
  }

  Widget _buildStatCol(FThemeData theme, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.statsStyle(
            context: context,
            baseStyle: theme.typography.lg.copyWith(color: theme.colors.foreground),
          ),
        ),
        Text(
          label,
          style: theme.typography.xs3.copyWith(color: theme.colors.foreground.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildLogrosGrid(FThemeData theme) {
    final insignias = _viewModel.insignias;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: insignias.length,
      itemBuilder: (context, index) {
        final logro = insignias[index];
        final obtenido = logro['obtenido'] as bool;
        
        return GestureDetector(
          onTap: () => _mostrarDetalleLogro(logro),
          child: FCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForInsignia(logro['key'] as String),
                  color: obtenido ? theme.colors.primary : theme.colors.mutedForeground,
                  size: 32,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      logro['titulo'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xs.copyWith(
                        fontWeight: FontWeight.w600,
                        color: obtenido ? theme.colors.foreground : theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
