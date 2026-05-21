import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'package:sugar_production/core/services/background_service.dart';
import 'package:sugar_production/core/services/notification.dart';
import 'package:sugar_production/core/services/theme_notifier.dart';

late final ThemeNotifier themeNotifier;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _hideSystemUI();

  // REQUEST PERMISSIONS
  await _requestPermissions();

  await AuthService().seedDefaultUsers();
  await NotificationUtils.init();
  await initBackgroundService();

  final service = FlutterBackgroundService();

  if (!await service.isRunning()) {
    await service.startService();
  }

  await AuthService().restoreSession();

  themeNotifier = await ThemeNotifier.load();

  runApp(const FarmManagementApp());
}

Future<void> _requestPermissions() async {
  // Notifications
  await Permission.notification.request();
  // Storage / Media
  if (await Permission.photos.isDenied) {
    await Permission.photos.request();
  }

  if (await Permission.storage.isDenied) {
    await Permission.storage.request();
  }

  // Optional for Android 13+
  if (await Permission.videos.isDenied) {
    await Permission.videos.request();
  }

  if (await Permission.audio.isDenied) {
    await Permission.audio.request();
  }

  // Ignore battery optimization (recommended for background service)
  await Permission.ignoreBatteryOptimizations.request();
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
