import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/historial_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../domain/models/residuo.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _viewModel = HistorialViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.cargarHistorial();
  }

  // ──────────────────────────────────────────────
  // CALC → Obtener color de contenedor según material
  // ──────────────────────────────────────────────
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

  // ──────────────────────────────────────────────
  // CALC → Obtener icono según material
  // ──────────────────────────────────────────────
  IconData _getIconForResiduo(Residuo residuo) {
    switch (residuo.material.toLowerCase()) {
      case 'plástico':
        return PhosphorIconsFill.drop;
      case 'papel':
      case 'cartón':
        return PhosphorIconsFill.package;
      case 'vidrio':
        return PhosphorIconsFill.wine;
      case 'metal':
        return PhosphorIconsFill.cylinder;
      case 'orgánico':
        return PhosphorIconsFill.leaf;
      default:
        return PhosphorIconsFill.trash;
    }
  }

  // ──────────────────────────────────────────────
  // CALC → Formatear fecha del residuo
  // ──────────────────────────────────────────────
  String _formatFecha(DateTime? date) {
    if (date == null) return 'Hace momentos';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'Hoy, hace ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'Hoy, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final listaFiltrada = _viewModel.residuosFiltrados;

        return FScaffold(
          header: FHeader(
            title: const Text('Historial'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gráfico de Barras (Tendencia Semanal)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Tendencia Semanal', style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                height: 180,
                child: _buildChart(theme),
              ),
              const SizedBox(height: 16),
              
              // Filtros de categoría
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: _viewModel.filtros.map((filtro) {
                    final isSelected = _viewModel.filtroActivo == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FButton(
                        variant: isSelected ? FButtonVariant.primary : FButtonVariant.outline,
                        size: FButtonSizeVariant.sm,
                        onPress: () => _viewModel.setFiltro(filtro),
                        child: Text(filtro),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              
              // Listado de Historial
              Expanded(
                child: _viewModel.isLoading
                    ? Center(child: FCircularProgress())
                    : listaFiltrada.isEmpty 
                        ? _buildEmptyState(theme) 
                        : RefreshIndicator(
                            onRefresh: _viewModel.cargarHistorial,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: listaFiltrada.length,
                              itemBuilder: (context, index) {
                                final item = listaFiltrada[index];
                                final matColor = _getColorForMaterial(item.material);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Bottom sheet opcional o detalle
                                    },
                                    child: FCard(
                                      child: Row(
                                        children: [
                                          // Icono del material correspondiente
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: matColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(_getIconForResiduo(item), color: matColor),
                                          ),
                                          const SizedBox(width: 16),
                                          // Detalles
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.tipo,
                                                  style: theme.typography.sm.copyWith(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _formatFecha(item.createdAt),
                                                  style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Peso / KG
                                          Text(
                                            '${item.pesoEstimadoKg} kg',
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(FThemeData theme) {
    final pesos = _viewModel.pesosPorDia;
    
    // Calcular el tope del eje Y dinámicamente con un 15% de margen (mínimo 5.0)
    double maxVal = 5.0;
    for (final p in pesos) {
      if (p > maxVal) maxVal = p;
    }
    final double maxY = maxVal + (maxVal * 0.15);

    return Padding(
      padding: const EdgeInsets.only(right: 24.0, left: 8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                  if (value.toInt() >= 0 && value.toInt() < dias.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dias[value.toInt()],
                        style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return _makeGroupData(index, pesos[index], theme.colors.primary);
          }),
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
