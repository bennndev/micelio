import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../viewmodels/escanear_viewmodel.dart';
import '../../theme/app_theme.dart';

class ProcesandoScreen extends StatefulWidget {
  const ProcesandoScreen({super.key});

  @override
  State<ProcesandoScreen> createState() => _ProcesandoScreenState();
}

class _ProcesandoScreenState extends State<ProcesandoScreen> with SingleTickerProviderStateMixin {
  final _viewModel = EscanearViewModel();
  
  final List<String> _loadingTexts = [
    "Analizando tu residuo...",
    "Consultando la red micelial...",
    "Identificando material...",
    "Calculando impacto ambiental..."
  ];
  
  int _textIndex = 0;
  Timer? _textTimer;
  bool _initialized = false;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted && !_viewModel.hasError && _viewModel.isProcessing) {
        setState(() {
          _textIndex = (_textIndex + 1) % _loadingTexts.length;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final imagePath = ModalRoute.of(context)?.settings.arguments as String?;
      _procesarAnalisis(imagePath ?? '');
    }
  }

  // ──────────────────────────────────────────────
  // HANDLE → Invocar análisis en el ViewModel
  // ──────────────────────────────────────────────
  Future<void> _procesarAnalisis(String imagePath) async {
    final resultado = await _viewModel.analizarFoto(imagePath);
    if (resultado != null && mounted) {
      Navigator.pushReplacementNamed(context, '/resultado', arguments: resultado);
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final imagePath = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return FScaffold(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.heroBackgroundGradient,
            ),
            child: SafeArea(
              child: _viewModel.hasError 
                  ? _buildErrorState(theme, imagePath) 
                  : _buildLoadingState(theme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(FThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: AppTheme.bioluminescentGlow(),
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/icon.png',
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const FCircularProgress(),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _loadingTexts[_textIndex],
            key: ValueKey<int>(_textIndex),
            style: theme.typography.lg.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.primaryForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(FThemeData theme, String imagePath) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsDuotone.warningCircle, size: 64, color: theme.colors.destructive),
            const SizedBox(height: 24),
            Text(
              'Interferencia en la red',
              style: theme.typography.xl2.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.primaryForeground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _viewModel.errorMessage ?? 'Hubo un error de conexión con la red micelial al procesar tu residuo.',
              textAlign: TextAlign.center,
              style: theme.typography.md.copyWith(
                color: theme.colors.primaryForeground.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 40),
            FButton(
              onPress: () => _procesarAnalisis(imagePath),
              child: const Text('Reintentar Análisis'),
            ),
            const SizedBox(height: 16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.pushReplacementNamed(context, '/inicio'),
              child: const Text('Ingresar manualmente'),
            ),
          ],
        ),
      ),
    );
  }
}
