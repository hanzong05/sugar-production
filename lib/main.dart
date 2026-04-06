import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'app.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'package:sugar_production/core/services/background_service.dart';
import 'package:sugar_production/core/services/notification.dart';
import 'package:sugar_production/core/services/theme_notifier.dart';

late final ThemeNotifier themeNotifier;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _hideSystemUI();

  SecurityContext.defaultContext.allowLegacyUnsafeRenegotiation = true;

  await NotificationUtils.init();
  await initBackgroundService();

  final service = FlutterBackgroundService();
  if (!await service.isRunning()) {
    await service.startService();
  }

  await AuthService().restoreSession();
  // await AuthService().seedDefaultUsers();

  themeNotifier = await ThemeNotifier.load();

  runApp(const FarmManagementApp());
}

void _hideSystemUI() {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}
