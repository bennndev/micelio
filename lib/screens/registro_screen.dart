import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _email = '';
  String _password = '';
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _email,
        password: _password,
        data: {
          'nombre_completo': _nombre,
        },
      );
      
      if (mounted) {
        if (res.session == null) {
          // Requiere confirmación de email según la configuración del proyecto Supabase
          setState(() {
            _successMessage = 'Revisa tu bandeja de entrada para confirmar tu correo.';
          });
        } else {
          // Inició sesión automáticamente
          Navigator.of(context).pushReplacementNamed('/inicio');
        }
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('already registered')) {
          _errorMessage = 'Este correo ya está registrado.';
        } else {
          _errorMessage = e.message;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado al registrarte.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              child: Column(
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
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: FAlert(
                        title: const Text('¡Registro exitoso!'),
                        subtitle: Text(_successMessage!),
                        icon: Icon(PhosphorIconsRegular.checkCircle, color: theme.colors.primaryForeground),
                      ),
                    ),

                  // Error Banner
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: FAlert(
                        title: const Text('Error de registro'),
                        subtitle: Text(_errorMessage!),
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
                          onPress: _isLoading ? null : _registrar,
                          child: _isLoading 
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
                          // Volver a login, limpiando la pila para evitar loops
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
