import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../data/repositories/auth_repository.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // ──────────────────────────────────────────────
  // HANDLE → Verificar sesión activa tras delay
  // ──────────────────────────────────────────────
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      if (_authRepository.estaAutenticado) {
        Navigator.of(context).pushReplacementNamed('/inicio');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E3E1A), Color(0xFF1C2214)],
              )
            : AppTheme.heroBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'Micelio Digital',
                style: FTheme.of(context).typography.xl4.copyWith(
                  color: FTheme.of(context).colors.primaryForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const FCircularProgress(),
            ],
          ),
        ),
      ),
    );
  }
}
