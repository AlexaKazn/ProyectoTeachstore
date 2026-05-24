import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TechStore360App());
}

class TechStore360App extends StatelessWidget {
  const TechStore360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TechStore 360',
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}