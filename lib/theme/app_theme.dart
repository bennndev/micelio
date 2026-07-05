import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clase centralizada para el tema de la aplicación "Micelio Digital".
/// Ninguna pantalla debe harcodear colores hex, todo debe consumirse
/// a través de [FTheme] o [Theme.of].
class AppTheme {
  AppTheme._();

  static FThemeData light({required bool touch}) {
    final colors = FColors(
      brightness: Brightness.light,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      barrier: const Color(0x33000000),
      background: const Color(0xFFFAF7EF), // Fondo claro neutro derivado del cream (#F5EBD3)
      foreground: const Color(0xFF2B2B1F), // Texto principal casi negro verdoso
      primary: const Color(0xFF7CB342),    // Verde vibrante
      primaryForeground: const Color(0xFF2B2B1F), // Texto oscuro sobre verde para WCAG AA (5.71:1)
      secondary: const Color(0xFFF5EBD3),  // Surface/cream para cards y cuerpo
      secondaryForeground: const Color(0xFF2B2B1F),
      muted: const Color(0xFFEADFBF),      // Cream desaturado/muted para estados deshabilitados
      mutedForeground: const Color(0xFF757560),
      destructive: const Color(0xFFC0392B), // Rojo desaturado estándar
      destructiveForeground: const Color(0xFFFFFFFF),
      error: const Color(0xFFC0392B),
      errorForeground: const Color(0xFFFFFFFF),
      card: const Color(0xFFF5EBD3),       // Surface/cream
      border: const Color(0xFF4E7A2E),     // Contornos primary dark para estética Kawaii marcada
    );

    final baseTypography = FTypography.inherit(colors: colors, touch: touch);
    final typography = FTypography(
      // Cuerpo y etiquetas con peso regular/medium
      xs3: GoogleFonts.dmSans(textStyle: baseTypography.xs3, fontWeight: FontWeight.normal),
      xs2: GoogleFonts.dmSans(textStyle: baseTypography.xs2, fontWeight: FontWeight.normal),
      xs: GoogleFonts.dmSans(textStyle: baseTypography.xs, fontWeight: FontWeight.normal),
      sm: GoogleFonts.dmSans(textStyle: baseTypography.sm, fontWeight: FontWeight.normal),
      md: GoogleFonts.dmSans(textStyle: baseTypography.md, fontWeight: FontWeight.normal),
      // Títulos y headers destacados con peso bold o semibold
      lg: GoogleFonts.dmSans(textStyle: baseTypography.lg, fontWeight: FontWeight.w600),
      xl: GoogleFonts.dmSans(textStyle: baseTypography.xl, fontWeight: FontWeight.bold),
      xl2: GoogleFonts.dmSans(textStyle: baseTypography.xl2, fontWeight: FontWeight.bold),
      xl3: GoogleFonts.dmSans(textStyle: baseTypography.xl3, fontWeight: FontWeight.bold),
      xl4: GoogleFonts.dmSans(textStyle: baseTypography.xl4, fontWeight: FontWeight.bold),
      xl5: GoogleFonts.dmSans(textStyle: baseTypography.xl5, fontWeight: FontWeight.bold),
      xl6: GoogleFonts.dmSans(textStyle: baseTypography.xl6, fontWeight: FontWeight.bold),
      xl7: GoogleFonts.dmSans(textStyle: baseTypography.xl7, fontWeight: FontWeight.bold),
      xl8: GoogleFonts.dmSans(textStyle: baseTypography.xl8, fontWeight: FontWeight.bold),
    );

    // Border radius global de 20px en botones, cards e inputs
    final borderRadius = FBorderRadius(
      xs2: const BorderRadius.all(Radius.circular(20)),
      xs: const BorderRadius.all(Radius.circular(20)),
      sm: const BorderRadius.all(Radius.circular(20)),
      md: const BorderRadius.all(Radius.circular(20)),
      lg: const BorderRadius.all(Radius.circular(20)),
      xl: const BorderRadius.all(Radius.circular(20)),
      xl2: const BorderRadius.all(Radius.circular(20)),
      xl3: const BorderRadius.all(Radius.circular(20)),
      pill: const BorderRadius.all(Radius.circular(100)), // Mantenemos la forma pill para tags especiales
    );

    final style = FStyle(
      formFieldStyle: FFormFieldStyle.inherit(colors: colors, typography: typography, touch: touch),
      focusedOutlineStyle: FFocusedOutlineStyle(color: colors.primary, borderRadius: borderRadius.md),
      sizes: FSizes.inherit(touch: touch),
      iconStyle: IconThemeData(color: colors.foreground, size: typography.lg.fontSize),
      tappableStyle: FTappableStyle(),
      borderRadius: borderRadius,
    );

    return FThemeData(
      colors: colors,
      touch: touch,
      typography: typography,
      style: style,
    );
  }

  static FThemeData dark({required bool touch}) {
    final colors = FColors(
      brightness: Brightness.dark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      barrier: const Color(0x7A000000),
      background: const Color(0xFF1C2214), // Fondo verde orgánico profundo
      foreground: const Color(0xFFF5EBD3), // Texto cream bioluminiscente
      primary: const Color(0xFF7CB342),    // Verde vibrante
      primaryForeground: const Color(0xFF1C2214), // Texto oscuro sobre verde para WCAG AA (7.07:1)
      secondary: const Color(0xFF2D3622),  // Oliva oscuro para cards e inputs
      secondaryForeground: const Color(0xFFF5EBD3),
      muted: const Color(0xFF22291A),
      mutedForeground: const Color(0xFF7D8D70),
      destructive: const Color(0xFFFF6467), // Rojo claro desaturado para el modo oscuro
      destructiveForeground: const Color(0xFF1C2214),
      error: const Color(0xFFFF6467),
      errorForeground: const Color(0xFF1C2214),
      card: const Color(0xFF2D3622),       // Oliva oscuro
      border: const Color(0xFF4E7A2E),     // Contorno primary dark
    );

    final baseTypography = FTypography.inherit(colors: colors, touch: touch);
    final typography = FTypography(
      xs3: GoogleFonts.dmSans(textStyle: baseTypography.xs3, fontWeight: FontWeight.normal),
      xs2: GoogleFonts.dmSans(textStyle: baseTypography.xs2, fontWeight: FontWeight.normal),
      xs: GoogleFonts.dmSans(textStyle: baseTypography.xs, fontWeight: FontWeight.normal),
      sm: GoogleFonts.dmSans(textStyle: baseTypography.sm, fontWeight: FontWeight.normal),
      md: GoogleFonts.dmSans(textStyle: baseTypography.md, fontWeight: FontWeight.normal),
      lg: GoogleFonts.dmSans(textStyle: baseTypography.lg, fontWeight: FontWeight.w600),
      xl: GoogleFonts.dmSans(textStyle: baseTypography.xl, fontWeight: FontWeight.bold),
      xl2: GoogleFonts.dmSans(textStyle: baseTypography.xl2, fontWeight: FontWeight.bold),
      xl3: GoogleFonts.dmSans(textStyle: baseTypography.xl3, fontWeight: FontWeight.bold),
      xl4: GoogleFonts.dmSans(textStyle: baseTypography.xl4, fontWeight: FontWeight.bold),
      xl5: GoogleFonts.dmSans(textStyle: baseTypography.xl5, fontWeight: FontWeight.bold),
      xl6: GoogleFonts.dmSans(textStyle: baseTypography.xl6, fontWeight: FontWeight.bold),
      xl7: GoogleFonts.dmSans(textStyle: baseTypography.xl7, fontWeight: FontWeight.bold),
      xl8: GoogleFonts.dmSans(textStyle: baseTypography.xl8, fontWeight: FontWeight.bold),
    );

    final borderRadius = FBorderRadius(
      xs2: const BorderRadius.all(Radius.circular(20)),
      xs: const BorderRadius.all(Radius.circular(20)),
      sm: const BorderRadius.all(Radius.circular(20)),
      md: const BorderRadius.all(Radius.circular(20)),
      lg: const BorderRadius.all(Radius.circular(20)),
      xl: const BorderRadius.all(Radius.circular(20)),
      xl2: const BorderRadius.all(Radius.circular(20)),
      xl3: const BorderRadius.all(Radius.circular(20)),
      pill: const BorderRadius.all(Radius.circular(100)),
    );

    final style = FStyle(
      formFieldStyle: FFormFieldStyle.inherit(colors: colors, typography: typography, touch: touch),
      focusedOutlineStyle: FFocusedOutlineStyle(color: colors.primary, borderRadius: borderRadius.md),
      sizes: FSizes.inherit(touch: touch),
      iconStyle: IconThemeData(color: colors.foreground, size: typography.lg.fontSize),
      tappableStyle: FTappableStyle(),
      borderRadius: borderRadius,
    );

    return FThemeData(
      colors: colors,
      touch: touch,
      typography: typography,
      style: style,
    );
  }

  /// Estilo de números / estadísticas destacadas con DM Sans Bold y ancho tabular.
  /// Evita que los números "tiemblen" o bailen al cambiar de ancho.
  static TextStyle statsStyle({required BuildContext context, TextStyle? baseStyle}) {
    final style = baseStyle ?? FTheme.of(context).typography.xl2;
    return GoogleFonts.dmSans(
      textStyle: style,
      fontWeight: FontWeight.bold,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Gradiente sutil bioluminiscente (#A8D842 → #F0E68C) para pantallas Hero.
  static const Gradient heroBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA8D842),
      Color(0xFFF0E68C),
    ],
  );

  /// Decoración con glow radial en tono #DCE775 para logros o rachas bioluminiscentes.
  static Decoration bioluminescentGlow() {
    return const BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          Color(0x99DCE775), // Verde lima con opacidad intermedia
          Color(0x00DCE775), // Transparente hacia los bordes
        ],
        stops: [0.2, 1.0],
      ),
    );
  }
}
