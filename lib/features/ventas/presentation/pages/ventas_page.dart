import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/venta_mensual_entity.dart';
import '../bloc/ventas_bloc.dart';

class VentasPage extends StatelessWidget {
  const VentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VentasBloc>()..add(LoadVentasEvent()),
      child: const _VentasView(),
    );
  }
}

class _VentasView extends StatelessWidget {
  const _VentasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: BlocBuilder<VentasBloc, VentasState>(
        builder: (ctx, state) {
          if (state is VentasLoading || state is VentasInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.ink));
          }
          if (state is VentasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error', style: AppTheme.bebasNeue(fontSize: 22, color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTheme.sourceSans(color: AppTheme.muted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ctx.read<VentasBloc>().add(LoadVentasEvent()),
                    child: const Text('REINTENTAR'),
                  ),
                ],
              ),
            );
          }
          if (state is VentasLoaded) {
            return RefreshIndicator(
              color: AppTheme.ink,
              onRefresh: () async => ctx.read<VentasBloc>().add(LoadVentasEvent()),
              child: CustomScrollView(
                slivers: [
                  _VentasSliverHeader(ventas: state.ventas),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _VentasChart(ventas: state.ventas),
                        const SizedBox(height: 20),
                        const _SectionTag(label: 'DETALLE POR MES'),
                        const SizedBox(height: 12),
                        ...state.ventas.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _VentaRow(venta: v),
                        )),
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

class _VentasSliverHeader extends StatelessWidget {
  final List<VentaMensualEntity> ventas;
  const _VentasSliverHeader({required this.ventas});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_US', symbol: '\$');
    final total = ventas.fold<double>(0, (a, b) => a + b.totalVentas);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REPORTES', style: AppTheme.sourceSans(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: AppTheme.muted)),
            const SizedBox(height: 2),
            Text('VENTAS', style: AppTheme.bebasNeue(fontSize: 36, letterSpacing: 3, color: AppTheme.ink)),
            const SizedBox(height: 4),
            Text('Total acumulado: ${fmt.format(total)}',
                style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.mutedDark)),
            const SizedBox(height: 20),
            Container(height: 1, color: AppTheme.border),
            const SizedBox(height: 20),
            const _SectionTag(label: 'GRÁFICO VENTAS MENSUALES'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _VentasChart extends StatelessWidget {
  final List<VentaMensualEntity> ventas;
  const _VentasChart({required this.ventas});

  @override
  Widget build(BuildContext context) {
    if (ventas.isEmpty) return const SizedBox();
    final maxY = ventas.map((v) => v.totalVentas).reduce((a, b) => a > b ? a : b) * 1.2;
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.ink,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '\$${(rod.toY / 1000).toStringAsFixed(1)}K',
                AppTheme.sourceSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.white),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= ventas.length) return const SizedBox();
                  final mes = ventas[i].nombreMes;
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(mes.length > 3 ? mes.substring(0, 3) : mes,
                        style: AppTheme.sourceSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted)),
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
          barGroups: ventas.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.totalVentas,
                color: AppTheme.ink,
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }
}

class _VentaRow extends StatelessWidget {
  final VentaMensualEntity venta;
  const _VentaRow({required this.venta});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_US', symbol: '\$');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                venta.mes.toString().padLeft(2, '0'),
                style: AppTheme.bebasNeue(fontSize: 18, letterSpacing: 1, color: AppTheme.ink),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venta.nombreMes,
                    style: AppTheme.sourceSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                Text('${venta.numTransacciones} transacciones · ${venta.totalUnidades} uds',
                    style: AppTheme.sourceSans(fontSize: 11, color: AppTheme.muted)),
              ],
            ),
          ),
          Text(fmt.format(venta.totalVentas),
              style: AppTheme.sourceSans(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
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
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.border, Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }
}
