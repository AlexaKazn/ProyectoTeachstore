import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: 'techstore2026');
  bool _obscure = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: AppTheme.cream,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthAuthenticated) ctx.go('/dashboard');
          },
          builder: (ctx, state) {
            final isLoading = state is AuthLoading;
            final hasError = state is AuthError;

            return Stack(
              children: [
                // ── Fondo degradado ──────────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.cream,
                          AppTheme.white,
                          AppTheme.cream,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Línea decorativa top ─────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        AppTheme.ink.withValues(alpha: 0.05),
                        AppTheme.ink.withValues(alpha: 0.15),
                        AppTheme.ink.withValues(alpha: 0.05),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),

                // ── Contenido ────────────────────────────────────────
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),

                            // ── Branding ─────────────────────────────
                            _Branding(),

                            const SizedBox(height: 32),

                            // ── Chips de capacidades ─────────────────
                            _CapabilityChips(),

                            const SizedBox(height: 36),

                            // ── Divisor ──────────────────────────────
                            const _Divider(label: 'ACCESO AL SISTEMA'),

                            const SizedBox(height: 28),

                            // ── Error ─────────────────────────────────
                            if (hasError) ...[
                              const _ErrorAlert(),
                              const SizedBox(height: 20),
                            ],

                            // ── Campo USUARIO ─────────────────────────
                            const _FieldLabel(label: 'USUARIO'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _usernameCtrl,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.sourceSans3(
                                  fontSize: 15, color: AppTheme.ink),
                              decoration: _fieldDecoration(
                                hint: 'admin',
                                icon: Feather.user,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Campo CONTRASEÑA ──────────────────────
                            const _FieldLabel(label: 'CONTRASEÑA'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              style: GoogleFonts.sourceSans3(
                                  fontSize: 15, color: AppTheme.ink),
                              onSubmitted: (_) => _submit(ctx),
                              decoration: _fieldDecoration(
                                hint: '••••••••',
                                icon: Feather.lock,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure ? Feather.eye_off : Feather.eye,
                                    color: AppTheme.muted,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Botón ─────────────────────────────────
                            _SubmitButton(
                              isLoading: isLoading,
                              onSubmit: () => _submit(ctx),
                            ),

                            const SizedBox(height: 32),

                            // ── Info módulos ──────────────────────────
                            const _Divider(label: 'MÓDULOS DISPONIBLES'),
                            const SizedBox(height: 20),
                            _ModulesGrid(),

                            const SizedBox(height: 32),

                            // ── Footer ─────────────────────────────────
                            _Footer(),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext ctx) {
    ctx.read<AuthBloc>().add(LoginEvent(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        ));
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.white,
      prefixIcon: Icon(icon, color: AppTheme.muted, size: 18),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppTheme.white, width: 1.5),
      ),
      hintStyle:
          GoogleFonts.sourceSans3(color: AppTheme.placeholder, fontSize: 14),
    );
  }
}

// ─── Branding ─────────────────────────────────────────────────────────────────

class _Branding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.ink.withValues(alpha: 0.05),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                    color: AppTheme.border, width: 1),
              ),
              child: const Icon(Feather.shopping_cart,
                  color: AppTheme.ink, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              'TechStore 360',
              style: GoogleFonts.bebasNeue(
                fontSize: 36,
                letterSpacing: 2,
                color: AppTheme.ink,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Plataforma Inteligente de Integración Empresarial',
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            color: AppTheme.mutedDark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Capability Chips ─────────────────────────────────────────────────────────

class _CapabilityChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const chips = [
      (Feather.database, 'Data Warehouse'),
      (Feather.cpu, 'IA & Patrones'),
      (Feather.bell, 'Alertas Twilio'),
      (Feather.bar_chart_2, 'Analytics'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(
                color: AppTheme.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(c.$1, color: AppTheme.inkLight, size: 12),
              const SizedBox(width: 6),
              Text(
                c.$2,
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Divider con label ────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.border,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.sourceSans3(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppTheme.mutedDark,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.border,
          ),
        ),
      ],
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.sourceSans3(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: AppTheme.mutedDark,
        ),
      );
}

// ─── Error Alert (FIXED: no mixed border colors + borderRadius) ───────────────

class _ErrorAlert extends StatelessWidget {
  const _ErrorAlert();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.dangerBg,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Borde izquierdo rojo como widget independiente
              Container(width: 4, color: AppTheme.danger),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Feather.alert_circle,
                            color: AppTheme.dangerText, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Credenciales incorrectas. Verifique e intente nuevamente.',
                          style: GoogleFonts.sourceSans3(
                              fontSize: 13, color: AppTheme.dangerText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;
  const _SubmitButton({required this.isLoading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.ink,
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: AppTheme.ink.withValues(alpha: 0.35),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'VERIFICANDO ACCESO...',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'INGRESAR AL SISTEMA',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Feather.arrow_right,
                      size: 16, color: AppTheme.white),
                ],
              ),
      ),
    );
  }
}

// ─── Modules Grid ─────────────────────────────────────────────────────────────

class _ModulesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const modules = [
      (Feather.grid, 'Dashboard', 'KPIs en tiempo real'),
      (Feather.bar_chart_2, 'Ventas', 'Reportes mensuales'),
      (Feather.box, 'Stock', 'Control de inventario'),
      (Feather.cpu, 'Predicciones', 'Modelos de IA'),
      (Feather.bell, 'Alertas', 'Notificaciones auto.'),
      (Feather.users, 'Clientes VIP', 'Segmentación'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) {
        final m = modules[i];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(
                color: AppTheme.border, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(m.$1, color: AppTheme.inkLight, size: 20),
              const SizedBox(height: 6),
              Text(
                m.$2,
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                m.$3,
                style: GoogleFonts.sourceSans3(
                  fontSize: 9,
                  color: AppTheme.mutedDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Feather.shield,
                size: 12, color: AppTheme.mutedDark),
            const SizedBox(width: 6),
            Text(
              'JWT SEGURO',
              style: GoogleFonts.sourceSans3(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppTheme.mutedDark,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 1,
              height: 10,
              color: AppTheme.border,
            ),
            const SizedBox(width: 10),
            const Icon(Feather.server,
                size: 12, color: AppTheme.mutedDark),
            const SizedBox(width: 6),
            Text(
              'API RENDER',
              style: GoogleFonts.sourceSans3(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppTheme.mutedDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '© 2026 TECHSTORE 360 · V2.0',
          style: GoogleFonts.sourceSans3(
            fontSize: 10,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
