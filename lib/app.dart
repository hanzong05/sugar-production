import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/layout.dart';
import 'package:sugar_production/features/auth/screens/login_screen.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FarmManagementApp extends StatefulWidget {
  const FarmManagementApp({super.key});

  @override
  State<FarmManagementApp> createState() => _FarmManagementAppState();
}

class _FarmManagementAppState extends State<FarmManagementApp>
    with WidgetsBindingObserver {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    themeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _auth.restoreSession();

      if (!_auth.isLoggedIn) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Sugar Production',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: _auth.isLoggedIn ? const AppLayout() : const LoginScreen(),
    );
  }
}
