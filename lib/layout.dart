import 'dart:async';
import 'package:flutter/material.dart';
import 'features/homepage/screens/homepage.dart';
import 'features/profile/screens/profile.dart';
import 'features/sync/screens/sync.dart';
import 'package:sugar_production/core/services/notification.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'features/homepage/widgets/bottom_navigation.dart';
import 'features/homepage/widgets/app_header.dart';
import 'package:sugar_production/features/notifications/screens/notification.dart';
import 'package:sugar_production/core/db.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 1;
  Timer? _notifTimer;
  final List<Widget> _pages = const [
    SyncScreen(),
    HomePage(),
    ProfilepageScreen(),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      NotificationUtils.handleAppLaunch();
      await Future.delayed(const Duration(milliseconds: 800));
      await NotificationUtils.checkPendingOnResume();
      await NotificationUtils.refreshUnreadcount();
    });
    _notifTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => NotificationUtils.checkPendingOnResume(),
    );
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppHeader(
        title: "Sugar Production App",
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
        outlineIcons: const [
          Icons.sync_outlined,
          Icons.home_outlined,
          Icons.person_outline,
        ],
        filledIcons: const [Icons.sync, Icons.home, Icons.person],
        labels: const ['Sync', 'Home', 'Profile'],
        isDark: isDark,
      ),
    );
  }
}
