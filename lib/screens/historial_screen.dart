import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String _filtroActivo = 'Todos';
  
  final List<String> _filtros = ['Todos', 'Plástico', 'Papel', 'Vidrio', 'Orgánico'];

  final List<Map<String, dynamic>> _historialTotal = [
    {
      'nombre': 'Botella PET',
      'material': 'Plástico',
      'fecha': 'Hoy, 14:30',
      'peso': 0.05,
      'icono': PhosphorIconsFill.drop,
    },
    {
      'nombre': 'Caja de Zapatos',
      'material': 'Papel',
      'fecha': 'Ayer, 09:15',
      'peso': 0.3,
      'icono': PhosphorIconsFill.package,
    },
    {
      'nombre': 'Botella de Vino',
      'material': 'Vidrio',
      'fecha': 'Hace 2 días',
      'peso': 0.8,
      'icono': PhosphorIconsFill.wine,
    },
    {
      'nombre': 'Cáscara de Plátano',
      'material': 'Orgánico',
      'fecha': 'Hace 3 días',
      'peso': 0.1,
      'icono': PhosphorIconsFill.leaf,
    },
    {
      'nombre': 'Envase de Yogur',
      'material': 'Plástico',
      'fecha': 'Hace 4 días',
      'peso': 0.02,
      'icono': PhosphorIconsFill.drop,
    },
  ];

  Color _getColorForMaterial(String material) {
    switch (material.toLowerCase()) {
      case 'plástico':
        return Colors.blue;
      case 'papel':
      case 'cartón':
        return Colors.amber;
      case 'vidrio':
        return Colors.green;
      case 'orgánico':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    
    final listaFiltrada = _filtroActivo == 'Todos' 
        ? _historialTotal 
        : _historialTotal.where((item) => item['material'] == _filtroActivo).toList();

    return FScaffold(
      header: FHeader(
        title: const Text('Historial'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gráfico de Barras
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Tendencia Semanal', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 180,
            child: _buildChart(theme),
          ),
          const SizedBox(height: 16),
          
          // Filtros tipo Chip (Row horizontal scrollable)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _filtros.map((filtro) {
                final isSelected = _filtroActivo == filtro;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FButton(
                    variant: isSelected ? FButtonVariant.primary : FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    onPress: () {
                      setState(() {
                        _filtroActivo = filtro;
                      });
                    },
                    child: Text(filtro),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          
          // Lista de historial
          Expanded(
            child: listaFiltrada.isEmpty 
                ? _buildEmptyState(theme) 
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) {
                      final item = listaFiltrada[index];
                      final matColor = _getColorForMaterial(item['material'] as String);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            // Bottom sheet opcional
                          },
                          child: FCard(
                            child: Row(
                              children: [
                                // Icono del contenedor
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: matColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(item['icono'] as IconData, color: matColor),
                                ),
                                const SizedBox(width: 16),
                                // Detalles
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nombre'] as String,
                                        style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['fecha'] as String,
                                        style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
                                      ),
                                    ],
                                  ),
                                ),
                                // Peso / KG
                                Text(
                                  '${item['peso']} kg',
                                  style: AppTheme.statsStyle(
                                    context: context,
                                    baseStyle: theme.typography.sm.copyWith(color: theme.colors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0, left: 8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dias[value.toInt()],
                      style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 5, theme.colors.primary),
            _makeGroupData(1, 6.5, theme.colors.primary),
            _makeGroupData(2, 5, theme.colors.primary),
            _makeGroupData(3, 7.5, theme.colors.primary),
            _makeGroupData(4, 9, theme.colors.primary),
            _makeGroupData(5, 4, theme.colors.primary),
            _makeGroupData(6, 6, theme.colors.primary),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildEmptyState(FThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsDuotone.ghost, size: 64, color: theme.colors.mutedForeground),
          const SizedBox(height: 16),
          Text(
            'Aún no has reciclado nada',
            style: theme.typography.md.copyWith(
              color: theme.colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus escaneos aparecerán aquí',
            style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
