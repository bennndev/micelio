import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onScanPressed;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12 + bottomInset, left: 16, right: 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            children: [
              // Píldora principal
              Expanded(
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: PhosphorIconsRegular.house,
                        activeIcon: PhosphorIconsFill.house,
                        label: 'Inicio',
                        isActive: currentIndex == 0,
                        onTap: () => onTabSelected(0),
                      ),
                      _NavItem(
                        icon: PhosphorIconsRegular.clockCounterClockwise,
                        activeIcon: PhosphorIconsFill.clockCounterClockwise,
                        label: 'Historial',
                        isActive: currentIndex == 1,
                        onTap: () => onTabSelected(1),
                      ),
                      _NavItem(
                        icon: PhosphorIconsRegular.user,
                        activeIcon: PhosphorIconsFill.user,
                        label: 'Perfil',
                        isActive: currentIndex == 2,
                        onTap: () => onTabSelected(2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón de cámara (FAB flotante)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onScanPressed();
                },
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIconsRegular.scan,
                      color: theme.colors.background,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    // Ya que el fondo es oscuro, los iconos y textos deben ser claros
    final color = widget.isActive ? theme.colors.background : theme.colors.background.withValues(alpha: 0.5);
    
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (!widget.isActive) {
            HapticFeedback.lightImpact();
            widget.onTap();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Center(
          child: AnimatedScale(
            scale: _isPressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isActive ? Colors.black.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      widget.isActive ? widget.activeIcon : widget.icon,
                      key: ValueKey(widget.isActive),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: color,
                        fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                      ),
                    ),
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


