import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/cliente_entity.dart';
import '../bloc/clientes_bloc.dart';

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClientesBloc>()..add(LoadClientesEvent()),
      child: const _ClientesView(),
    );
  }
}

class _ClientesView extends StatelessWidget {
  const _ClientesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: BlocBuilder<ClientesBloc, ClientesState>(
        builder: (context, state) {
          if (state is ClientesLoading || state is ClientesInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.ink));
          }
          if (state is ClientesError) {
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
                      onPressed: () => context.read<ClientesBloc>().add(LoadClientesEvent()),
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is ClientesLoaded) {
            return RefreshIndicator(
              color: AppTheme.ink,
              onRefresh: () async => context.read<ClientesBloc>().add(LoadClientesEvent()),
              child: CustomScrollView(
                slivers: [
                  const _ClientesSliverHeader(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTag(label: 'TOP CLIENTES POR GASTO'),
                          const SizedBox(height: 10),
                          _ChartCard(clientes: state.clientes),
                          const SizedBox(height: 20),
                          const _SectionTag(label: 'DIRECTORIO VIP'),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ClienteCard(cliente: state.clientes[i], index: i + 1),
                        ),
                        childCount: state.clientes.length,
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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

class _ClientesSliverHeader extends StatelessWidget {
  const _ClientesSliverHeader();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MÓDULO', style: AppTheme.sourceSans(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3, color: AppTheme.muted)),
            const SizedBox(height: 2),
            Text('CLIENTES VIP', style: AppTheme.bebasNeue(fontSize: 36, letterSpacing: 3, color: AppTheme.ink)),
            const SizedBox(height: 20),
            Container(height: 1, color: AppTheme.border),
          ],
        ),
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

class _ChartCard extends StatelessWidget {
  final List<ClienteEntity> clientes;
  const _ChartCard({required this.clientes});

  @override
  Widget build(BuildContext context) {
    if (clientes.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.white, 
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(child: Text('Sin datos',
            style: AppTheme.sourceSans(color: AppTheme.muted))),
      );
    }
    
    // Sort by gasto desc and take top 5
    final sorted = List<ClienteEntity>.from(clientes)..sort((a, b) => b.totalGastado.compareTo(a.totalGastado));
    final topClientes = sorted.take(5).toList();
    final maxGasto = topClientes.map((c) => c.totalGastado).reduce((a, b) => a > b ? a : b);

    final fmt = NumberFormat.currency(locale: 'es_US', symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          ...topClientes.map((cliente) {
            final widthFactor = (cliente.totalGastado / maxGasto).clamp(0.0, 1.0);
            final nombreArr = cliente.nombre.split(' ');
            final shortName = nombreArr.length > 1 ? '${nombreArr[0]} ${nombreArr[1][0]}.' : nombreArr[0];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(shortName, 
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
                              color: AppTheme.chartPalette[2], // Using the chart palette instead of mutedDark
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                cliente.totalGastado >= 1000 
                                  ? '\$${(cliente.totalGastado / 1000).toStringAsFixed(1)}K'
                                  : fmt.format(cliente.totalGastado),
                                style: AppTheme.sourceSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.ink), // Letra más pequeña
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
                    Text('\$0', style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                    Text('\$${(maxGasto/2000).toStringAsFixed(0)}K', style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                    Text('\$${(maxGasto/1000).toStringAsFixed(0)}K', style: AppTheme.sourceSans(fontSize: 9, color: AppTheme.muted)),
                  ]
                )
              )
            ]
          )
        ],
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final ClienteEntity cliente;
  final int index;
  const _ClienteCard({required this.cliente, required this.index});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_US', symbol: '\$');
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppTheme.cream),
                child: Center(child: Text('#$index', style: AppTheme.sourceSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.mutedDark))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nombre, style: AppTheme.sourceSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)), // Letra pequeña
                    const SizedBox(height: 2),
                    Text(cliente.correo, style: AppTheme.sourceSans(fontSize: 11, color: AppTheme.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Feather.map_pin, size: 12, color: AppTheme.muted),
              const SizedBox(width: 6),
              Text(cliente.ciudad, style: AppTheme.sourceSans(fontSize: 12, color: AppTheme.mutedDark)),
              const Spacer(),
              const Icon(Feather.shopping_bag, size: 12, color: AppTheme.muted),
              const SizedBox(width: 6),
              Text('${cliente.numCompras} compras', style: AppTheme.sourceSans(fontSize: 12, color: AppTheme.mutedDark)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL GASTADO', style: AppTheme.sourceSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppTheme.muted)),
                    Text(fmt.format(cliente.totalGastado), style: AppTheme.bebasNeue(fontSize: 20, letterSpacing: 1, color: AppTheme.ink)), // Más pequeña
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TICKET PROMEDIO', style: AppTheme.sourceSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppTheme.muted)),
                    Text(fmt.format(cliente.ticketPromedio), style: AppTheme.bebasNeue(fontSize: 20, letterSpacing: 1, color: AppTheme.ink)), // Más pequeña
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
