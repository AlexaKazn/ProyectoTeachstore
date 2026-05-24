import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/prediccion_entity.dart';
import '../bloc/predicciones_bloc.dart';

class PrediccionesPage extends StatelessWidget {
  const PrediccionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PrediccionesBloc>()..add(LoadPrediccionesEvent()),
      child: const _PrediccionesView(),
    );
  }
}

class _PrediccionesView extends StatelessWidget {
  const _PrediccionesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: BlocBuilder<PrediccionesBloc, PrediccionesState>(
        builder: (ctx, state) {
          if (state is PrediccionesLoading || state is PrediccionesInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.ink));
          }
          if (state is PrediccionesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error', style: AppTheme.bebasNeue(fontSize: 22, color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTheme.sourceSans(color: AppTheme.muted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ctx.read<PrediccionesBloc>().add(LoadPrediccionesEvent()),
                    child: const Text('REINTENTAR'),
                  ),
                ],
              ),
            );
          }
          if (state is PrediccionesLoaded) {
            return RefreshIndicator(
              color: AppTheme.ink,
              onRefresh: () async => ctx.read<PrediccionesBloc>().add(LoadPrediccionesEvent()),
              child: CustomScrollView(
                slivers: [
                  _PrediccionesSliverHeader(total: state.predicciones.length),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (state.predicciones.isNotEmpty) ...[
                          _PrediccionesChart(predicciones: state.predicciones),
                          const SizedBox(height: 20),
                          const _SectionTag(label: 'DETALLE PREDICCIONES'),
                          const SizedBox(height: 12),
                          ...state.predicciones.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PrediccionCard(prediccion: p),
                          )),
                        ],
                        if (state.recomendaciones.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const _SectionTag(label: 'RECOMENDACIONES IA'),
                          const SizedBox(height: 12),
                          ...state.recomendaciones.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecomendacionCard(rec: r),
                          )),
                        ],
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _PrediccionesSliverHeader extends StatelessWidget {
  final int total;
  const _PrediccionesSliverHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MÓDULO DE', style: AppTheme.sourceSans(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: AppTheme.muted)),
            const SizedBox(height: 2),
            Text('PREDICCIONES', style: AppTheme.bebasNeue(fontSize: 36, letterSpacing: 3, color: AppTheme.ink)),
            const SizedBox(height: 4),
            Text('$total meses proyectados',
                style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.mutedDark)),
            const SizedBox(height: 20),
            Container(height: 1, color: AppTheme.border),
            const SizedBox(height: 20),
            const _SectionTag(label: 'PROYECCIÓN DE VENTAS'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PrediccionesChart extends StatelessWidget {
  final List<PrediccionEntity> predicciones;
  const _PrediccionesChart({required this.predicciones});

  @override
  Widget build(BuildContext context) {
    if (predicciones.isEmpty) return const SizedBox();
    final spots = predicciones.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), e.value.ventasPredichas)).toList();
    final maxY = predicciones.map((p) => p.ventasPredichas).reduce((a, b) => a > b ? a : b) * 1.2;

    final lineBar = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppTheme.chartPalette[3],
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4, color: AppTheme.white,
          strokeWidth: 2, strokeColor: AppTheme.chartPalette[3],
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppTheme.chartPalette[3].withValues(alpha: 0.1),
      ),
    );

    return Container(
      height: 240, // Made a bit taller to fit data labels
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: LineChart(
        LineChartData(
          minY: 0, maxY: maxY,
          showingTooltipIndicators: spots.asMap().keys.map((index) {
            return ShowingTooltipIndicators([LineBarSpot(lineBar, 0, spots[index])]);
          }).toList(),
          lineBarsData: [lineBar],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) {
                  if (value == 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('\$${(value / 1000).toInt()}K',
                        style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= predicciones.length) return const SizedBox();
                  final mes = predicciones[i].nombreMes;
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(mes.length > 3 ? mes.substring(0, 3) : mes,
                        style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppTheme.border, strokeWidth: 1, dashArray: [4, 4]),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.ink,
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                '\$${(s.y / 1000).toStringAsFixed(1)}K',
                AppTheme.sourceSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.white),
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrediccionCard extends StatelessWidget {
  final PrediccionEntity prediccion;
  const _PrediccionCard({required this.prediccion});

  @override
  Widget build(BuildContext context) {
    final isPositive = prediccion.tasaCrecimiento >= 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(prediccion.mes.toString().padLeft(2, '0'),
                  style: AppTheme.bebasNeue(fontSize: 20, letterSpacing: 1, color: AppTheme.ink)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prediccion.nombreMes,
                    style: AppTheme.sourceSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                Text('${prediccion.unidadesPredichas} unidades · ${prediccion.modelo}',
                    style: AppTheme.sourceSans(fontSize: 11, color: AppTheme.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${(prediccion.ventasPredichas / 1000).toStringAsFixed(1)}K',
                  style: AppTheme.sourceSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
              Row(
                children: [
                  Icon(
                    isPositive ? Feather.arrow_up : Feather.arrow_down,
                    size: 11,
                    color: isPositive ? AppTheme.mutedDark : AppTheme.danger,
                  ),
                  Text('${prediccion.tasaCrecimiento.abs().toStringAsFixed(1)}%',
                      style: AppTheme.sourceSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: isPositive ? AppTheme.mutedDark : AppTheme.danger)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecomendacionCard extends StatelessWidget {
  final RecomendacionEntity rec;
  const _RecomendacionCard({required this.rec});

  IconData _icon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'STOCK': return Feather.box;
      case 'VENTA': case 'VENTAS': return Feather.trending_up;
      case 'CLIENTE': case 'CLIENTES': return Feather.users;
      default: return Ionicons.bulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(_icon(rec.tipo), color: AppTheme.ink, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.tipo,
                    style: AppTheme.sourceSans(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 2, color: AppTheme.muted)),
                const SizedBox(height: 2),
                Text(rec.descripcion,
                    style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.ink)),
                if (rec.accion != null) ...[
                  const SizedBox(height: 4),
                  Text(rec.accion!,
                      style: AppTheme.sourceSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppTheme.mutedDark)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  final String label;
  const _SectionTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTheme.sourceSans(
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 3, color: AppTheme.muted)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.border, Colors.transparent]))),
        ),
      ],
    );
  }
}
