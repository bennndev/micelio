import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:micelio_app/theme/app_theme.dart';
import 'package:micelio_app/screens/splash_screen.dart';
import 'package:micelio_app/screens/escanear_screen.dart';
import 'package:micelio_app/screens/procesando_screen.dart';
import 'package:micelio_app/screens/resultado_screen.dart';
import 'package:micelio_app/screens/main_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final themeData = _isDark ? AppTheme.dark(touch: true) : AppTheme.light(touch: true);

    return FTheme(
      data: themeData,
      child: MaterialApp(
        title: 'Micelio Digital',
        debugShowCheckedModeBanner: false,
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFAF7EF),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1C2214),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/inicio': (context) => const MainShell(),
          '/escanear': (context) => const EscanearScreen(),
          '/procesando': (context) => const ProcesandoScreen(),
          '/resultado': (context) => const ResultadoScreen(),
        },
      ),
    );
  }
}

class MicelioShowcasePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const MicelioShowcasePage({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<MicelioShowcasePage> createState() => _MicelioShowcasePageState();
}

class _MicelioShowcasePageState extends State<MicelioShowcasePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  int _streakCount = 7; // Racha de días del usuario

  @override
  void dispose() {
    _textController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los tokens activos de Forui
    final theme = FTheme.of(context);

    return FScaffold(
      // 5. Encabezado de página centralizado usando FHeader de Forui
      header: FHeader(
        title: Text(
          'Micelio Digital',
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
        ),
        suffixes: [
          // Botón para alternar tema
          FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: widget.onThemeToggle,
            child: Icon(
              widget.isDark
                  ? PhosphorIconsRegular.sun
                  : PhosphorIconsRegular.moon,
              size: 20,
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Pantalla/Sección Hero (Inicio) con gradiente bioluminiscente sutil
              _buildHeroSection(theme),
              const SizedBox(height: 24),

              // Sección: Botones y Variantes
              _buildSectionTitle(theme, '1. Botones y Radio de 20px'),
              const SizedBox(height: 12),
              _buildButtonsCard(theme),
              const SizedBox(height: 24),

              // Sección: Inputs y Formularios
              _buildSectionTitle(theme, '2. Inputs y Formularios (Radius 20px)'),
              const SizedBox(height: 12),
              _buildFormCard(theme),
              const SizedBox(height: 24),

              // Sección: Estadísticas y Racha Bioluminiscente
              _buildSectionTitle(theme, '3. Logros, Rachas y Estadísticas'),
              const SizedBox(height: 12),
              _buildStatsAndGlowCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(FThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        text,
        style: theme.typography.sm.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colors.foreground.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  // Render del Hero con el gradiente y el diseño del hongo kawaii
  Widget _buildHeroSection(FThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        // Aplicamos el gradiente bioluminiscente en modo Light o una atenuación en modo Dark
        gradient: widget.isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2E3E1A), // Verde bioluminiscente oscuro
                  const Color(0xFF1C2214), // Fondo de la app
                ],
              )
            : AppTheme.heroBackgroundGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colors.border,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          // Área del Hongo Kawaii sobre un glow bioluminiscente
          Stack(
            alignment: Alignment.center,
            children: [
              // 6. Glow radial para mantener la identidad bioluminiscente
              Container(
                width: 160,
                height: 160,
                decoration: AppTheme.bioluminescentGlow(),
              ),
              // Representación visual kawai del Hongo con brote
              _buildKawaiiMushroom(theme),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¡Tu Micelio está vivo!',
            style: theme.typography.xl.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isDark ? theme.colors.foreground : const Color(0xFF2B2B1F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitorea el crecimiento de tu red digital con una paleta orgánica y accesible.',
            style: theme.typography.xs.copyWith(
              color: (widget.isDark ? theme.colors.foreground : const Color(0xFF2B2B1F))
                  .withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dibujo vectorial simple con widgets para recrear el hongo kawaii del icono
  Widget _buildKawaiiMushroom(FThemeData theme) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tallo del hongo (Cuerpo cream)
          Positioned(
            bottom: 10,
            child: Container(
              width: 55,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF5EBD3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                  top: Radius.circular(15),
                ),
                border: Border.all(
                  color: const Color(0xFF4E7A2E), // Contornos oscuros
                  width: 2.5,
                ),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  // Ojos Kawaii
                  Positioned(
                    top: 18,
                    left: 10,
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: Color(0xFF2B2B1F),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 10,
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: Color(0xFF2B2B1F),
                    ),
                  ),
                  // Sonrisa
                  Positioned(
                    top: 25,
                    child: Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 14,
                      color: Color(0xFF2B2B1F),
                    ),
                  ),
                  // Mejillas rosadas
                  Positioned(
                    top: 22,
                    left: 4,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFE59866),
                    ),
                  ),
                  Positioned(
                    top: 22,
                    right: 4,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFE59866),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sombrero del hongo (Verde con brote)
          Positioned(
            top: 10,
            child: Container(
              width: 95,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF7CB342), // Primary
                borderRadius: const BorderRadius.all(Radius.elliptical(50, 35)),
                border: Border.all(
                  color: const Color(0xFF4E7A2E), // Contornos oscuros
                  width: 2.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Detalles del sombrero (Manchas circulares más claras)
                  Positioned(
                    top: 10,
                    left: 15,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: const Color(0xFFDCE775).withValues(alpha: 0.6),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: const Color(0xFFDCE775).withValues(alpha: 0.6),
                    ),
                  ),
                  // Brote Kawaii (Símbolo en el centro)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0x30FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIconsFill.leaf,
                        color: const Color(0xFFDCE775), // Accent verde lima
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta demostrando los botones temados
  Widget _buildButtonsCard(FThemeData theme) {
    return FCard(
      title: Text('FButton Showcase', style: theme.typography.md.copyWith(fontWeight: FontWeight.bold)),
      subtitle: const Text('Todos los botones heredan el radius global de 20px.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Botón Primario: texto oscuro #2B2B1F para cumplir WCAG AA (5.71:1)
          FButton(
            variant: FButtonVariant.primary,
            onPress: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsFill.checkCircle, size: 20, color: theme.colors.primaryForeground),
                const SizedBox(width: 8),
                const Text('Botón Primario (WCAG AA)'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FButton(
            variant: FButtonVariant.secondary,
            onPress: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.cards, size: 20, color: theme.colors.secondaryForeground),
                const SizedBox(width: 8),
                const Text('Botón Secundario (Cream)'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.leaf, size: 20, color: theme.colors.foreground),
                const SizedBox(width: 8),
                const Text('Botón Outline'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FButton(
            variant: FButtonVariant.destructive,
            onPress: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsFill.trash, size: 20, color: theme.colors.destructiveForeground),
                const SizedBox(width: 8),
                const Text('Botón Destructivo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta con formulario inputs de 20px
  Widget _buildFormCard(FThemeData theme) {
    return FCard(
      title: Text('Inputs del Sistema', style: theme.typography.md.copyWith(fontWeight: FontWeight.bold)),
      subtitle: const Text('Bordes redondeados de 20px y tipografía DM Sans.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          FTextField(
            label: Text('Nombre de tu Cepa', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
            hint: 'Ej. Pleurotus Ostreatus...',
            // En forui 0.21.3 la propiedad controller está expuesta
            // Para el ejemplo, podemos interactuar
          ),
          const SizedBox(height: 16),
          FTextField.password(
            label: Text('Llave de Seguridad', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
            hint: 'Ingresa tu contraseña secreta',
          ),
        ],
      ),
    );
  }

  // Tarjeta de Logros, Racha y números tabulares
  Widget _buildStatsAndGlowCard(FThemeData theme) {
    return FCard(
      title: Text('Rendimiento y Gamificación', style: theme.typography.md.copyWith(fontWeight: FontWeight.bold)),
      subtitle: const Text('Comprobación de números tabulares y racha bioluminiscente.'),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Rila de estadísticas con números tabulares
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(theme, '254', 'Esporas hoy'),
              const SizedBox(
                height: 40,
                child: VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
              ),
              _buildStatItem(theme, '99.8%', 'Humedad red'),
            ],
          ),
          const Divider(height: 32),
          // Componente de Racha con animación bioluminiscente interactiva
          Text(
            'Racha de Cuidado',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _streakCount++;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow radial bioluminiscente (#DCE775)
                Container(
                  width: 110,
                  height: 110,
                  decoration: AppTheme.bioluminescentGlow(),
                ),
                // Círculo central con la racha
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colors.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono Phosphor Duotone / Fill
                      PhosphorIcon(
                        PhosphorIconsDuotone.flame,
                        color: const Color(0xFFDCE775), // Accent lima
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_streakCount',
                        style: AppTheme.statsStyle(
                          context: context,
                          baseStyle: theme.typography.xl.copyWith(
                            color: theme.colors.primaryForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Toca la llama para sumar días a tu racha!',
            style: theme.typography.xs.copyWith(color: theme.colors.foreground.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(FThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          // 3. Números y estadísticas en DM Sans Bold ( tabular )
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
