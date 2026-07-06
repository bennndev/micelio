import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class ProcesandoScreen extends StatefulWidget {
  const ProcesandoScreen({super.key});

  @override
  State<ProcesandoScreen> createState() => _ProcesandoScreenState();
}

class _ProcesandoScreenState extends State<ProcesandoScreen> with SingleTickerProviderStateMixin {
  final List<String> _loadingTexts = [
    "Analizando tu residuo...",
    "Consultando la red micelial...",
    "Identificando material...",
    "Calculando impacto ambiental..."
  ];
  
  int _textIndex = 0;
  Timer? _textTimer;
  Timer? _timeoutTimer;
  bool _hasError = false;

  // Controlador para animación de pulso del hongo
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animación de pulso
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Cambiar texto cada 2.5 segundos
    _textTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted && !_hasError) {
        setState(() {
          _textIndex = (_textIndex + 1) % _loadingTexts.length;
        });
      }
    });

    // Iniciar simulación de llamada a Gemini
    _simulateGeminiVision();
  }

  void _simulateGeminiVision() {
    setState(() {
      _hasError = false;
    });
    
    // Timeout de seguridad de 8 segundos
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_hasError) {
        setState(() {
          _hasError = true;
        });
      }
    });

    // Simulamos la respuesta de la API que tarda unos 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_hasError) {
        _timeoutTimer?.cancel();
        
        // Mock JSON de clasificación
        final mockResult = {
          "nombre": "Botella de Plástico PET",
          "material": "Plástico",
          "reciclable": true,
          "puntos": 15,
          "instrucciones": "Vacía el contenido, enjuaga brevemente y aplasta la botella antes de depositarla."
        };

        Navigator.pushReplacementNamed(context, '/resultado', arguments: mockResult);
      }
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _timeoutTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    
    // Obtenemos la ruta de la imagen pasada desde el scanner (opcional)
    final imagePath = ModalRoute.of(context)?.settings.arguments as String?;

    return FScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.heroBackgroundGradient,
        ),
        child: SafeArea(
          child: _hasError ? _buildErrorState(theme) : _buildLoadingState(theme, imagePath),
        ),
      ),
    );
  }

  Widget _buildLoadingState(FThemeData theme, String? imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animación central pulsante con glow bioluminiscente
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
        
        // Indicador circular estilizado
        const FCircularProgress(),
        const SizedBox(height: 24),
        
        // Texto dinámico con animación de opacidad cruzada
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

  Widget _buildErrorState(FThemeData theme) {
    return Padding(
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
            'El análisis tardó demasiado o hubo un error de conexión con el modelo de visión.',
            textAlign: TextAlign.center,
            style: theme.typography.md.copyWith(
              color: theme.colors.primaryForeground.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 40),
          FButton(
            onPress: _simulateGeminiVision,
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
    );
  }
}
