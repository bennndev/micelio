import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../theme/app_theme.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Simular 1.5s de delay, luego verificar sesión Supabase (mock)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      // Si no hay sesión activa, esto se resolverá luego con onboarding.
      // Por ahora siempre navega a '/inicio' sin poder volver atrás.
      Navigator.of(context).pushReplacementNamed('/inicio');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      // Utilizamos el FScaffold pero el fondo será nuestro gradiente Hero.
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.heroBackgroundGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Image.asset(
              'assets/images/icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            // Título
            Text(
              'Micelio Digital',
              style: FTheme.of(context).typography.xl4.copyWith(
                color: FTheme.of(context).colors.primaryForeground,
              ),
            ),
            const SizedBox(height: 32),
            // Indicador de carga sutil (FCircularProgress de forui)
            const FCircularProgress(),
          ],
        ),
      ),
    );
  }
}
