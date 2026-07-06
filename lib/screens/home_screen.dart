import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Inicio'),
        suffixes: [
          FHeaderAction(
            icon: PhosphorIcon(PhosphorIconsDuotone.gear),
            onPress: () {},
          ),
        ],
      ),
      child: const Center(
        child: Text('Bienvenido a Micelio Digital'),
      ),
    );
  }
}
