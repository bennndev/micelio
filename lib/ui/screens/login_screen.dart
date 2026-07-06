import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = LoginViewModel();
  String _email = '';
  String _password = '';

  // ──────────────────────────────────────────────
  // HANDLE → Procesar el login del usuario
  // ──────────────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    await _viewModel.login(_email, _password);
    // La navegación a '/inicio' es manejada por el listener de AuthStateChange en main.dart
  }

  // ──────────────────────────────────────────────
  // HANDLE → Procesar login con Google OAuth
  // ──────────────────────────────────────────────
  Future<void> _loginWithGoogle() async {
    await _viewModel.loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 90,
                          height: 90,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Header
                      Text(
                        'Bienvenido de vuelta',
                        style: theme.typography.xl3.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reciclar nunca fue tan fácil',
                        style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Error Banner
                      if (_viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: FAlert(
                            title: const Text('Error de acceso'),
                            subtitle: Text(_viewModel.errorMessage!),
                            icon: Icon(PhosphorIconsRegular.warningCircle, color: theme.colors.destructiveForeground),
                          ),
                        ),

                      // Formulario
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email
                            FTextFormField(
                              label: Text('Correo Electrónico', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                              hint: 'tu@email.com',
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (value) => _email = value?.trim() ?? '',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'El correo es requerido';
                                if (!value.contains('@') || !value.contains('.')) return 'Ingresa un correo válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Password
                            FTextFormField.password(
                              label: Text('Contraseña', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                              hint: '••••••••',
                              onSaved: (value) => _password = value ?? '',
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'La contraseña es requerida';
                                if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                                return null;
                              },
                            ),
                            
                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/recuperar-password');
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: theme.typography.sm.copyWith(
                                    color: theme.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            FButton(
                              variant: FButtonVariant.primary,
                              onPress: _viewModel.isLoading ? null : _login,
                              child: _viewModel.isLoading 
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Separador Visual
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.colors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'o continúa con',
                              style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.colors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Botones Sociales
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: _viewModel.isLoading ? null : _loginWithGoogle,
                        prefix: Icon(Icons.login, size: 20, color: theme.colors.foreground),
                        child: const Text('Google'),
                      ),
                      const SizedBox(height: 32),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta?',
                            style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/registro');
                            },
                            child: Text(
                              'Regístrate',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
