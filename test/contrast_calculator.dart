import 'dart:math';

double getRelativeLuminance(String hexColor) {
  // Eliminar '#' si está presente
  String hex = hexColor.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  int val = int.parse(hex, radix: 16);
  
  double r = ((val >> 16) & 0xFF) / 255.0;
  double g = ((val >> 8) & 0xFF) / 255.0;
  double b = (val & 0xFF) / 255.0;

  r = r <= 0.04045 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4).toDouble();
  g = g <= 0.04045 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4).toDouble();
  b = b <= 0.04045 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double getContrastRatio(String hex1, String hex2) {
  double l1 = getRelativeLuminance(hex1);
  double l2 = getRelativeLuminance(hex2);

  double brightest = max(l1, l2);
  double darkest = min(l1, l2);

  return (brightest + 0.05) / (darkest + 0.05);
}

void main() {
  var tests = [
    // [Color1, Color2, Descripción]
    ['#2B2B1F', '#F5EBD3', 'Texto principal (#2B2B1F) sobre Cream (#F5EBD3)'],
    ['#2B2B1F', '#7CB342', 'Texto principal (#2B2B1F) sobre Primary (#7CB342)'],
    ['#FFFFFF', '#7CB342', 'Blanco (#FFFFFF) sobre Primary (#7CB342)'],
    ['#F5EBD3', '#7CB342', 'Cream (#F5EBD3) sobre Primary (#7CB342)'],
    ['#4E7A2E', '#F5EBD3', 'Primary Dark (#4E7A2E) sobre Cream (#F5EBD3)'],
    ['#4E7A2E', '#FFFFFF', 'Primary Dark (#4E7A2E) sobre Blanco (#FFFFFF)'],
    ['#FFFFFF', '#4E7A2E', 'Blanco (#FFFFFF) sobre Primary Dark (#4E7A2E)'],
    ['#2B2B1F', '#DCE775', 'Texto principal (#2B2B1F) sobre Accent/glow (#DCE775)'],
  ];

  for (var t in tests) {
    double ratio = getContrastRatio(t[0], t[1]);
    print('${t[2]}: ${ratio.toStringAsFixed(2)}:1 ${ratio >= 4.5 ? "✅ CUMPLE WCAG AA (>= 4.5)" : ratio >= 3.0 ? "⚠️ CUMPLE SOLO TEXTO GRANDE (>= 3.0)" : "❌ NO CUMPLE (< 3.0)"}');
  }
}
