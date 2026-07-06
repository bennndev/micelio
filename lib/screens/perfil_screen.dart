import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificacionesActivas = true;
  bool _isSigningOut = false;

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

  // TODO: Obtener estos datos desde las tablas `usuarios` y `estadisticas` usando Supabase.
  // Actualmente inicializados en su estado por defecto real (0/vacío).
  final String userLevel = "Recolector Novato";
  final double progressToNextLevel = 0.0;
  
  final double kgTotal = 0.0;
  final double co2Evitado = 0.0;
  final int maxRacha = 0;

  final List<Map<String, dynamic>> logros = [
    {'titulo': 'Primer Escaneo', 'icono': PhosphorIconsFill.medal, 'obtenido': true, 'desc': 'Escaneaste tu primer residuo exitosamente.'},
    {'titulo': 'Experto en Vidrio', 'icono': PhosphorIconsFill.wine, 'obtenido': true, 'desc': 'Has reciclado más de 10 envases de vidrio.'},
    {'titulo': 'Racha 7 Días', 'icono': PhosphorIconsFill.flame, 'obtenido': true, 'desc': 'Mantuviste una racha de reciclaje por una semana entera.'},
    {'titulo': 'Guardián del Bosque', 'icono': PhosphorIconsFill.tree, 'obtenido': false, 'desc': 'Recicla 100 kg en total para desbloquear.'},
  ];

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
              Navigator.pop(context); // Cierra el diálogo
              setState(() => _isSigningOut = true);
              await Supabase.instance.client.auth.signOut();
              // El listener global en main.dart detectará el signedOut y redirigirá a /login
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
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
                    onPress: _isSigningOut ? null : _cerrarSesion,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSigningOut)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else
                          Icon(PhosphorIconsRegular.signOut, color: theme.colors.destructiveForeground),
                        const SizedBox(width: 8),
                        Text(_isSigningOut ? 'Cerrando sesión...' : 'Cerrar sesión'),
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
            _avatarUrl != null
                ? FAvatar(
                    image: NetworkImage(_avatarUrl!) as ImageProvider<Object>,
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
                        _iniciales, 
                        style: theme.typography.xl.copyWith(fontWeight: FontWeight.bold, color: theme.colors.primaryForeground)
                      )
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_nombreUsuario, style: theme.typography.xl2.copyWith(fontWeight: FontWeight.bold)),
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
        childAspectRatio: 1.2,
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
