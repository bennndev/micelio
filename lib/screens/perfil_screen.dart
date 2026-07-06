import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificacionesActivas = true;

  // Mock data
  final String userName = "Micelio";
  final String userLevel = "Recolector Novato";
  final double progressToNextLevel = 0.65;
  
  final double kgTotal = 42.5;
  final double co2Evitado = 15.2;
  final int maxRacha = 14;

  final List<Map<String, dynamic>> logros = [
    {'titulo': 'Primer Escaneo', 'icono': PhosphorIconsFill.medal, 'obtenido': true, 'desc': 'Escaneaste tu primer residuo exitosamente.'},
    {'titulo': 'Experto en Vidrio', 'icono': PhosphorIconsFill.wine, 'obtenido': true, 'desc': 'Has reciclado más de 10 envases de vidrio.'},
    {'titulo': 'Racha 7 Días', 'icono': PhosphorIconsFill.flame, 'obtenido': true, 'desc': 'Mantuviste una racha de reciclaje por una semana entera.'},
    {'titulo': 'Guardián del Bosque', 'icono': PhosphorIconsFill.tree, 'obtenido': false, 'desc': 'Recicla 100 kg en total para desbloquear.'},
  ];

  void _cerrarSesion() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

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

    return FScaffold(
      header: FHeader(
        title: const Text('Mi Perfil'),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera del Perfil
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

            // Preferencias y Ajustes
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
                    onPress: _cerrarSesion,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIconsRegular.signOut, color: theme.colors.destructiveForeground),
                        const SizedBox(width: 8),
                        const Text('Cerrar sesión'),
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
            FAvatar(
              image: const AssetImage('assets/images/icon.png'),
              size: 80,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(userName, style: theme.typography.xl2.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        FBadge(
          variant: FBadgeVariant.secondary,
          child: Text(userLevel),
        ),
        const SizedBox(height: 24),
        FCard(
          title: Text('Siguiente Nivel: Guardián', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
          subtitle: const Text('Faltan 350 puntos'),
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: FDeterminateProgress(value: progressToNextLevel),
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
          _buildStatCol(theme, '$kgTotal kg', 'Reciclados', PhosphorIconsDuotone.recycle),
          Container(width: 1, height: 40, color: theme.colors.border),
          _buildStatCol(theme, '$co2Evitado kg', 'CO₂ Evitado', PhosphorIconsDuotone.cloud),
          Container(width: 1, height: 40, color: theme.colors.border),
          _buildStatCol(theme, '$maxRacha', 'Días Racha', PhosphorIconsDuotone.flame),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: logros.length,
      itemBuilder: (context, index) {
        final logro = logros[index];
        final obtenido = logro['obtenido'] as bool;
        
        return GestureDetector(
          onTap: () => _mostrarDetalleLogro(logro),
          child: FCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  logro['icono'],
                  color: obtenido ? theme.colors.primary : theme.colors.mutedForeground,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  logro['titulo'],
                  textAlign: TextAlign.center,
                  style: theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: obtenido ? theme.colors.foreground : theme.colors.mutedForeground,
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
