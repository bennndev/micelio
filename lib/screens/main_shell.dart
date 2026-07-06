import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'inicio_screen.dart';
import 'historial_screen.dart';
import 'perfil_screen.dart';
import '../widgets/premium_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onScanPressed() {
    Navigator.pushNamed(context, '/escanear');
  }

  int get _stackIndex {
    return _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    
    return FScaffold(
      // Usamos un Stack para poder poner la barra flotante por encima del contenido
      child: Stack(
        children: [
          // Contenido principal con padding inferior para no quedar oculto por la barra
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100 + bottomInset), // Espacio para la barra flotante
              child: IndexedStack(
                index: _stackIndex,
                children: const [
                  InicioScreen(),
                  HistorialScreen(),
                  PerfilScreen(),
                ],
              ),
            ),
          ),
          
          // Barra de navegación flotante
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PremiumBottomNav(
              currentIndex: _currentIndex,
              onTabSelected: _onNavChange,
              onScanPressed: _onScanPressed,
            ),
          ),
        ],
      ),
    );
  }
}
