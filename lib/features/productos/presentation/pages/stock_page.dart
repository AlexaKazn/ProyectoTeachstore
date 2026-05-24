import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/producto_entity.dart';
import '../bloc/productos_bloc.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductosBloc>()..add(LoadProductosEvent()),
      child: const _StockView(),
    );
  }
}

class _StockView extends StatelessWidget {
  const _StockView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: BlocBuilder<ProductosBloc, ProductosState>(
        builder: (ctx, state) {
          if (state is ProductosLoading || state is ProductosInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.ink));
          }
          if (state is ProductosError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error al cargar', style: AppTheme.bebasNeue(fontSize: 22, color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTheme.sourceSans(color: AppTheme.muted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ctx.read<ProductosBloc>().add(LoadProductosEvent()),
                    child: const Text('REINTENTAR'),
                  ),
                ],
              ),
            );
          }
          if (state is ProductosLoaded) {
            return RefreshIndicator(
              color: AppTheme.ink,
              onRefresh: () async => ctx.read<ProductosBloc>().add(LoadProductosEvent()),
              child: CustomScrollView(
                slivers: [
                  _StockSliverHeader(
                      stockCount: state.stock.length,
                      topCount: state.top.length),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (state.stock.isNotEmpty) ...[
                          const _SectionTag(label: 'STOCK CRÍTICO'),
                          const SizedBox(height: 12),
                          _StockBarChart(stock: state.stock),
                          const SizedBox(height: 20),
                        ],
                        const _SectionTag(label: 'TOP PRODUCTOS'),
                        const SizedBox(height: 12),
                        _TopProductosPieChart(top: state.top),
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

class _StockSliverHeader extends StatelessWidget {
  final int stockCount;
  final int topCount;
  const _StockSliverHeader({required this.stockCount, required this.topCount});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INVENTARIO', style: AppTheme.sourceSans(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: AppTheme.muted)),
            const SizedBox(height: 2),
            Text('STOCK', style: AppTheme.bebasNeue(fontSize: 36, letterSpacing: 3, color: AppTheme.ink)),
            const SizedBox(height: 4),
            Text('$stockCount productos en alerta · Top $topCount más vendidos',
                style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.mutedDark)),
            const SizedBox(height: 20),
            Container(height: 1, color: AppTheme.border),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StockBarChart extends StatelessWidget {
  final List<StockItemEntity> stock;
  const _StockBarChart({required this.stock});

  @override
  Widget build(BuildContext context) {
    final maxStock = stock.isEmpty ? 100 : stock.map((e) => e.stock).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          ...stock.map((item) {
            final widthFactor = (item.stock / maxStock).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(item.producto, 
                      style: AppTheme.sourceSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.mutedDark),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 24,
                              width: constraints.maxWidth * widthFactor,
                              color: AppTheme.chartPalette[2],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                '${item.stock} uds',
                                style: AppTheme.sourceSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.ink),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          // X-Axis
          Row(
            children: [
              const SizedBox(width: 80),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0', style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                    Text('${(maxStock/2).toInt()}', style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                    Text('$maxStock', style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                  ]
                )
              )
            ]
          )
        ]
      )
    );
  }
}

class _TopProductosPieChart extends StatelessWidget {
  final List<ProductoTopEntity> top;
  const _TopProductosPieChart({required this.top});

  @override
  Widget build(BuildContext context) {
    if (top.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.white, 
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(child: Text('Sin datos',
            style: AppTheme.sourceSans(color: AppTheme.muted))),
      );
    }
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: top.asMap().entries.map((e) {
                  final i = e.key;
                  final prod = e.value;
                  return PieChartSectionData(
                    color: AppTheme.chartPalette[i % AppTheme.chartPalette.length],
                    value: prod.ingresosTotales,
                    title: '${(prod.ingresosTotales / 1000).toInt()}K',
                    radius: 40,
                    titleStyle: AppTheme.sourceSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: top.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        color: AppTheme.chartPalette[e.key % AppTheme.chartPalette.length],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e.value.producto, 
                          style: AppTheme.sourceSans(fontSize: 10, color: AppTheme.mutedDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      )
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
