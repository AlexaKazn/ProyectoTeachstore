import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/alerta_entity.dart';
import '../bloc/alertas_bloc.dart';

class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AlertasBloc>()..add(LoadAlertasEvent()),
      child: const _AlertasView(),
    );
  }
}

class _AlertasView extends StatelessWidget {
  const _AlertasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: BlocBuilder<AlertasBloc, AlertasState>(
        builder: (context, state) {
          if (state is AlertasLoading || state is AlertasInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.ink));
          }
          if (state is AlertasError) {
            return _ErrorView(message: state.message,
                onRetry: () => context.read<AlertasBloc>().add(LoadAlertasEvent()));
          }
          if (state is AlertasLoaded) {
            return RefreshIndicator(
              color: AppTheme.ink,
              onRefresh: () async => context.read<AlertasBloc>().add(LoadAlertasEvent()),
              child: CustomScrollView(
                slivers: [
                  _AlertasSliverHeader(total: state.alertas.length),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: state.alertas.isEmpty
                        ? const SliverToBoxAdapter(child: _EmptyAlertas())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AlertaCard(alerta: state.alertas[i]),
                              ),
                              childCount: state.alertas.length,
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

class _AlertasSliverHeader extends StatelessWidget {
  final int total;
  const _AlertasSliverHeader({required this.total});

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
            Text('ALERTAS', style: AppTheme.bebasNeue(fontSize: 36, letterSpacing: 3, color: AppTheme.ink)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: total > 0 ? AppTheme.dangerBg : AppTheme.white,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      color: total > 0 ? AppTheme.dangerBorder : AppTheme.border),
                  ),
                  child: Text(
                    '$total ${total == 1 ? 'alerta activa' : 'alertas activas'}',
                    style: AppTheme.sourceSans(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: total > 0 ? AppTheme.dangerText : AppTheme.inkLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: AppTheme.border),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final AlertaEntity alerta;
  const _AlertaCard({required this.alerta});

  Color _urgencyColor(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'ALTO': case 'HIGH': return AppTheme.danger;
      case 'MEDIO': case 'MEDIUM': return AppTheme.mutedDark;
      default: return AppTheme.border;
    }
  }

  Color _urgencyBg(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'ALTO': case 'HIGH': return AppTheme.dangerBg;
      case 'MEDIO': case 'MEDIUM': return AppTheme.white;
      default: return AppTheme.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _urgencyColor(alerta.nivelUrgencia);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(alerta.producto,
                              style: AppTheme.sourceSans(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _urgencyBg(alerta.nivelUrgencia),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(alerta.nivelUrgencia,
                              style: AppTheme.sourceSans(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5, color: color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Feather.shopping_cart, size: 13, color: AppTheme.muted),
                        const SizedBox(width: 4),
                        Text(alerta.sucursal,
                            style: AppTheme.sourceSans(fontSize: 12, color: AppTheme.mutedDark)),
                        const SizedBox(width: 16),
                        const Icon(Feather.box, size: 13, color: AppTheme.muted),
                        const SizedBox(width: 4),
                        Text('Stock: ${alerta.stock} Unidades',
                            style: AppTheme.sourceSans(
                                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(alerta.tipoAlerta.replaceAll('_', ' '),
                        style: AppTheme.sourceSans(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            letterSpacing: 1.5, color: AppTheme.muted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlertas extends StatelessWidget {
  const _EmptyAlertas();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppTheme.white, shape: BoxShape.rectangle, // Cuadrado
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Feather.check_circle,
                color: AppTheme.inkLight, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Sin alertas activas',
              style: AppTheme.bebasNeue(fontSize: 22, letterSpacing: 2, color: AppTheme.ink)),
          const SizedBox(height: 4),
          Text('Todos los niveles de stock son adecuados.',
              style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.muted)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Feather.wifi_off, size: 48, color: AppTheme.muted),
            const SizedBox(height: 16),
            Text('Error al cargar alertas',
                style: AppTheme.bebasNeue(fontSize: 22, letterSpacing: 2, color: AppTheme.ink)),
            const SizedBox(height: 8),
            Text(message, style: AppTheme.sourceSans(fontSize: 12, color: AppTheme.muted),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry,
                child: const Text('REINTENTAR')),
          ],
        ),
      ),
    );
  }
}
