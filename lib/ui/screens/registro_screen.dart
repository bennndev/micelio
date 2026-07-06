import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../viewmodels/registro_viewmodel.dart';
import '../../theme/app_theme.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = RegistroViewModel();
  String _nombre = '';
  String _email = '';
  String _password = '';

  // ──────────────────────────────────────────────
  // HANDLE → Procesar registro de usuario
  // ──────────────────────────────────────────────
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    final res = await _viewModel.registrar(
      nombre: _nombre,
      email: _email,
      password: _password,
    );

    if (res != null && res.session != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/inicio');
    }
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
                      // Logo más pequeño
                      Center(
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 70,
                          height: 70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Header
                      Text(
                        'Crea tu cuenta',
                        style: theme.typography.xl3.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Únete a la red y empieza a reciclar',
                        style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Success Banner
                      if (_viewModel.successMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: FAlert(
                            title: const Text('¡Registro exitoso!'),
                            subtitle: Text(_viewModel.successMessage!),
                            icon: Icon(PhosphorIconsRegular.checkCircle, color: theme.colors.primaryForeground),
                          ),
                        ),

                      // Error Banner
                      if (_viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: FAlert(
                            title: const Text('Error de registro'),
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
                            // Nombre Completo
                            FTextFormField(
                              label: Text('Nombre Completo', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                              hint: 'Ej. Juan Pérez',
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              onSaved: (value) => _nombre = value?.trim() ?? '',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'El nombre es requerido';
                                if (value.trim().length < 2) return 'El nombre es muy corto';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

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
                            const SizedBox(height: 32),

                            // Register Button
                            FButton(
                              variant: FButtonVariant.primary,
                              onPress: _viewModel.isLoading ? null : _registrar,
                              child: _viewModel.isLoading 
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Crear cuenta'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta?',
                            style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'Inicia sesión',
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
