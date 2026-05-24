import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/navigation_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(LoadDashboardEvent()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.ink));
          }
          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Feather.wifi_off, size: 48, color: AppTheme.muted),
                    const SizedBox(height: 16),
                    Text('Error al cargar', style: AppTheme.bebasNeue(fontSize: 22, color: AppTheme.ink)),
                    const SizedBox(height: 8),
                    Text(state.message, style: AppTheme.sourceSans(fontSize: 12, color: AppTheme.muted),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardBloc>().add(LoadDashboardEvent()),
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              color: AppTheme.ink,
              onRefresh: () async => context.read<DashboardBloc>().add(LoadDashboardEvent()),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashHeader(),
                    const SizedBox(height: 20),
                    _StatsGrid(summary: state.summary),
                    const SizedBox(height: 20),
                    const _SectionTag(label: 'VENTAS MENSUALES'),
                    const SizedBox(height: 10),
                    _ChartCard(summary: state.summary),
                    const SizedBox(height: 20),
                    const _SectionTag(label: 'INDICADORES CLAVE'),
                    const SizedBox(height: 10),
                    _IndicadoresRow(summary: state.summary),
                    const SizedBox(height: 20),
                    const _SectionTag(label: 'ACCESO RÁPIDO'),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BIENVENIDO AL', style: AppTheme.sourceSans(
            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: AppTheme.muted)),
        const SizedBox(height: 2),
        Text('PANEL DE CONTROL',
            style: AppTheme.bebasNeue(fontSize: 36, letterSpacing: 3, color: AppTheme.ink)),
        Text('Gestión central · TechStore 360',
            style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.mutedDark)),
      ],
    );
  }
}

// ─── Section tag ─────────────────────────────────────────────────────────────

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

// ─── Stats grid ──────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardSummaryEntity summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_US', symbol: '\$');
    final stats = [
      _StatData(
        title: 'VENTAS TOTALES',
        value: summary.totalVentas >= 1000
            ? '\$${(summary.totalVentas / 1000).toStringAsFixed(1)}K'
            : fmt.format(summary.totalVentas),
        sub: 'Ingresos totales',
        accent: false,
      ),
      _StatData(
        title: 'CLIENTES',
        value: summary.totalClientes.toString(),
        sub: 'Activos en el sistema',
        accent: false,
      ),
      _StatData(
        title: 'PRODUCTOS',
        value: summary.totalProductos.toString(),
        sub: 'En catálogo',
        accent: false,
      ),
      _StatData(
        title: 'ALERTAS',
        value: summary.alertasPendientes.toString(),
        sub: 'Requieren atención',
        accent: summary.alertasPendientes > 0,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14, mainAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, i) => _StatCard(data: stats[i]),
    );
  }
}

class _StatData {
  final String title, value, sub;
  final bool accent;
  const _StatData({
    required this.title, required this.value,
    required this.sub, required this.accent,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: data.accent ? AppTheme.dangerBorder : AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: AppTheme.sourceSans(
              fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 1.5, color: AppTheme.muted)),
          const Spacer(),
          Text(data.value, style: AppTheme.bebasNeue(
              fontSize: 30, letterSpacing: 1,
              color: data.accent ? AppTheme.danger : AppTheme.ink)),
          const SizedBox(height: 2),
          Text(data.sub, style: AppTheme.sourceSans(fontSize: 10, color: AppTheme.muted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Chart card ──────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final DashboardSummaryEntity summary;
  const _ChartCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.ventasMensuales.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.white, borderRadius: BorderRadius.zero,
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(child: Text('Sin datos de ventas',
            style: AppTheme.sourceSans(color: AppTheme.muted))),
      );
    }
    final maxY = summary.ventasMensuales
            .map((v) => v.total)
            .reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: false, // Tooltips are shown permanently now
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 8,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '\$${(rod.toY / 1000).toStringAsFixed(1)}K',
                  AppTheme.sourceSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.ink),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, _) {
                    if (value == 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('\$${(value / 1000).toInt()}K',
                          style: AppTheme.sourceSans(
                              fontSize: 9, color: AppTheme.muted)),
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
                    final idx = value.toInt();
                    if (idx < 0 || idx >= summary.ventasMensuales.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        summary.ventasMensuales[idx].mes.toUpperCase(),
                        style: AppTheme.sourceSans(
                            fontSize: 9, fontWeight: FontWeight.w600,
                            letterSpacing: 0.5, color: AppTheme.muted),
                      ),
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
            barGroups: summary.ventasMensuales.asMap().entries.map((e) =>
              BarChartGroupData(
                x: e.key,
                showingTooltipIndicators: [0], // Show tooltip index 0 permanently
                barRods: [
                  BarChartRodData(
                    toY: e.value.total,
                    color: AppTheme.chartPalette[2],
                    width: 28, // Más ancho
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              )).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Indicadores ─────────────────────────────────────────────────────────────

class _IndicadoresRow extends StatelessWidget {
  final DashboardSummaryEntity summary;
  const _IndicadoresRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MiniIndicador(
          label: 'STOCK CRÍTICO',
          value: summary.stockCritico.toString(),
          icon: Feather.box,
          color: summary.stockCritico > 0 ? AppTheme.danger : AppTheme.ink,
          onTap: () => context.read<NavigationCubit>().changeTab(2), // Índice 2 es Stock
        )),
        const SizedBox(width: 14),
        Expanded(child: _MiniIndicador(
          label: 'CLIENTES VIP',
          value: summary.clientesVip.toString(),
          icon: Feather.users,
          color: AppTheme.ink,
          onTap: () => context.read<NavigationCubit>().changeTab(1), // Índice 1 es Clientes
        )),
        const SizedBox(width: 14),
        Expanded(child: _MiniIndicador(
          label: 'ALERTAS',
          value: summary.alertasActivas.toString(),
          icon: Feather.bell,
          color: summary.alertasActivas > 0 ? AppTheme.danger : AppTheme.muted,
          onTap: () => context.read<NavigationCubit>().changeTab(4), // Índice 4 es Alertas
        )),
      ],
    );
  }
}

class _MiniIndicador extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _MiniIndicador({
    required this.label, required this.value,
    required this.icon, required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: AppTheme.bebasNeue(fontSize: 24, letterSpacing: 1, color: color)),
            Text(label, style: AppTheme.sourceSans(
                fontSize: 8, fontWeight: FontWeight.w700,
                letterSpacing: 1, color: AppTheme.muted),
                textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }
}