---
design-system:
  name: Micelio Digital Design System
  version: 1.0.0
  inspiration: Kawaii bioluminescent mushroom theme
  tokens:
    colors:
      primary: "#7CB342" # Verde vibrante
      primary-dark: "#4E7A2E" # Contornos e interacciones (Pressed)
      accent: "#DCE775" # Verde lima (glows y logros)
      surface-cream: "#F5EBD3" # Fondo de cards y inputs
      text-dark: "#2B2B1F" # Texto principal (casi negro verdoso)
      background-light: "#FAF7EF" # Derivado cálido muy claro del cream
      background-dark: "#1C2214" # Verde orgánico oscuro profundo
      error: "#C0392B" # Rojo desaturado
    border-radius:
      global: 20px
    typography:
      font-family: "DM Sans"
      headers: "Bold / SemiBold"
      body: "Regular / Medium"
      numbers: "Bold (Tabular Figures)"
    iconography:
      package: phosphor_flutter
      preferred-styles: ["fill", "duotone"]
---

# Micelio Digital - Especificación del Sistema de Diseño

Este documento define las bases visuales, la accesibilidad y las restricciones del diseño para **Micelio Digital**. Funciona como un contrato técnico y visual de obligado cumplimiento tanto para desarrolladores humanos como para agentes de Inteligencia Artificial (IA).

---

## 1. Filosofía del Diseño

El diseño de **Micelio Digital** está inspirado en la naturaleza y la gamificación kawaii. Busca proyectar una estética orgánica, viva y suave (redondeada), con acentos bioluminiscentes verde-amarillos que simulan una red de esporas digital activa.

### Principios Fundamentales:
1. **Estética Orgánica:** Bordes muy redondeados y contornos oscuros que asemejan una ilustración.
2. **Bioluminiscencia:** Uso de glows y gradientes radiales para destacar logros y actividad.
3. **Accesibilidad Científica:** Ratios de contraste comprobados que cumplen con la norma WCAG AA.

---

## 2. Tokens de Color y Accesibilidad (WCAG AA)

### Tabla de Equivalencias de Color
| Token de Diseño | Código Hexadecimal | Propósito Visual |
| :--- | :--- | :--- |
| **Primary** | `#7CB342` | Color principal de marca, fondo de botones CTAs. |
| **Primary Dark** | `#4E7A2E` | Contornos y estados de interacción (pressed/hover). |
| **Accent / Glow** | `#DCE775` | Verde lima brillante usado en glows de logros y rachas. |
| **Surface / Cream** | `#F5EBD3` | Fondo de tarjetas (cards), campos de texto (inputs) y modales. |
| **Background (Light)**| `#FAF7EF` | Fondo general de la aplicación en modo claro (cálido). |
| **Background (Dark)** | `#1C2214` | Fondo general de la aplicación en modo oscuro (verde orgánico). |
| **Foreground (Light)**| `#2B2B1F` | Texto principal casi negro verdoso. Evita el negro puro. |
| **Foreground (Dark)** | `#F5EBD3` | Texto principal en modo oscuro. Reutiliza el cream para un look retro cálido. |
| **Error** | `#C0392B` | Rojo desaturado que no rompe la armonía de la paleta. |

### Contratos de Contraste WCAG AA (Verificados):
Para asegurar legibilidad en personas con discapacidades visuales, se aplican las siguientes reglas:
* **FRENTE A PRIMARY (`#7CB342`):** El texto claro (blanco o cream) está **estrictamente prohibido** debido a su bajo ratio de contraste (2.5:1). Se debe utilizar **obligatoriamente** el color de texto oscuro `#2B2B1F` (`primaryForeground`), el cual provee un ratio seguro de **5.71:1** ✅.
* **FRENTE A CREAM (`#F5EBD3`):** El texto oscuro `#2B2B1F` provee un ratio de **12.06:1** ✅, superando con creces la norma AA (4.5:1).
* **EN MODO OSCURO:** El texto Cream `#F5EBD3` sobre el fondo verde profundo `#1C2214` ofrece un contraste óptimo de **14.3:1** ✅.

---

## 3. Tipografía (DM Sans)

Toda la aplicación utiliza exclusivamente la fuente de Google Fonts **"DM Sans"**.

* **Títulos y Encabezados:** Deben renderizarse en peso **Bold** (w700) o **SemiBold** (w600).
* **Cuerpo y Etiquetas:** Deben usar peso **Regular** (w400) o **Medium** (w500).
* **Números y Estadísticas:** Deben usar peso **Bold** (w700) y aplicar obligatoriamente la propiedad de fuente de **ancho tabular** (`tabularFigures`) para prevenir que la interfaz "salte" o tiemble al cambiar dinámicamente los valores numéricos.
  * *Implementación en Flutter:* `fontFeatures: const [FontFeature.tabularFigures()]`

---

## 4. Estilos y Formas Orgánicas

* **Border Radius Global:** Todos los botones (`FButton`), campos de texto (`FTextField`) y tarjetas (`FCard`) deben tener un radio de esquina de **20px** (`FBorderRadius(xs2...xl3: 20)`).
* **Glow Bioluminiscente:** Para destacar rachas y logros, no se debe utilizar confeti genérico. En su lugar, se implementará un **glow radial** con gradiente desde `#DCE775` con opacidad hasta transparente, evocando bioluminiscencia de hongos.
* **Iconografía:** Se utiliza `phosphor_flutter`. Se prefieren íconos en su variante **duotone** o **fill** (ej. `PhosphorIconsDuotone.flame` o `PhosphorIconsFill.leaf`) con trazo suave y grueso, evitando el outline delgado para encajar con el estilo kawaii de ilustración.

---

## 5. Reglas de Implementación para Desarrolladores e IA

### LO QUE SE DEBE HACER (Do's) ✅
* Utilizar siempre `AppTheme.light()` y `AppTheme.dark()` para inicializar el tema a nivel global.
* Consumir colores y tipografías dinámicamente vía `FTheme.of(context)` o `Theme.of(context)`.
* Usar `AppTheme.statsStyle()` al renderizar cualquier marcador, contador o porcentaje destacado.
* Aplicar el gradiente `AppTheme.heroBackgroundGradient` únicamente en pantallas principales o portadas hero (Inicio). El resto de pantallas deben usar el fondo neutro cálido.

### LO QUE NO SE DEBE HACER (Don'ts) ❌
* **Nunca** hardcodear valores hexadecimales de color directamente en los archivos de UI de las pantallas.
* **Nunca** colocar texto blanco o crema sobre botones con fondo primario verde.
* **Nunca** usar el `Scaffold` estándar de Material sin envolver los componentes dentro de la infraestructura visual de `forui`.
* **Nunca** usar un border-radius menor a 20px en botones o entradas de texto, a menos que sea una etiqueta especial de forma píldora (`pill`).
