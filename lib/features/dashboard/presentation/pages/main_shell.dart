import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/navigation_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../alertas/presentation/pages/alertas_page.dart';
import '../../../clientes/presentation/pages/clientes_page.dart';
import '../../../predicciones/presentation/pages/predicciones_page.dart';
import '../../../productos/presentation/pages/stock_page.dart';
import 'dashboard_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NavigationCubit>(),
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatefulWidget {
  const _MainShellView();

  @override
  State<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<_MainShellView> {
  final List<Widget> _pages = const [
    DashboardPage(),
    ClientesPage(), // Índice 1: Clientes VIP (reemplaza Ventas)
    StockPage(),
    PrediccionesPage(),
    AlertasPage(),
  ];

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: AppConstants.tokenKey);
    await storage.delete(key: AppConstants.usernameKey);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          backgroundColor: AppTheme.cream,
          appBar: _MainAppBar(onLogout: _logout),
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: _MainBottomNav(
            currentIndex: currentIndex,
            onTap: (index) => context.read<NavigationCubit>().changeTab(index),
          ),
        );
      },
    );
  }
}

// ─── AppBar ──────────────────────────────────────────────────────────────────

class _MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  const _MainAppBar({required this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.inkLight,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Feather.grid, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text('TECHSTORE 360',
              style: AppTheme.bebasNeue(fontSize: 22, letterSpacing: 3, color: AppTheme.white)),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Feather.bell, color: Colors.white70, size: 22),
              onPressed: () {},
            ),
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent,
                  boxShadow: [BoxShadow(color: AppTheme.accent, blurRadius: 6, spreadRadius: 1)],
                ),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppTheme.border),
          ),
          color: AppTheme.white,
          onSelected: (val) {
            if (val == 'logout') onLogout();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Feather.log_out, size: 16, color: AppTheme.danger),
                  const SizedBox(width: 8),
                  Text('Cerrar sesión',
                      style: AppTheme.sourceSans(fontSize: 13, color: AppTheme.danger)),
                ],
              ),
            ),
          ],
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              color: AppTheme.ink,
            ),
            child: Center(
              child: Text('A',
                  style: AppTheme.sourceSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.white)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _MainBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      BottomNavigationBarItem(
        icon: Icon(Feather.grid),
        activeIcon: Icon(Ionicons.grid),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Feather.users),
        activeIcon: Icon(Ionicons.people),
        label: 'Clientes VIP',
      ),
      BottomNavigationBarItem(
        icon: Icon(Feather.box),
        activeIcon: Icon(Ionicons.cube),
        label: 'Stock',
      ),
      BottomNavigationBarItem(
        icon: Icon(Feather.cpu),
        activeIcon: Icon(Ionicons.hardware_chip),
        label: 'IA',
      ),
      BottomNavigationBarItem(
        icon: Icon(Feather.bell),
        activeIcon: Icon(Ionicons.notifications),
        label: 'Alertas',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.ink,
        unselectedItemColor: AppTheme.muted,
        selectedLabelStyle: AppTheme.sourceSans(
            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        unselectedLabelStyle: AppTheme.sourceSans(fontSize: 10),
        elevation: 0,
        items: items,
      ),
    );
  }
}
