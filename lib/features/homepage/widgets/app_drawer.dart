import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'package:sugar_production/features/auth/screens/login_screen.dart';
import 'package:sugar_production/features/notifications/screens/notification.dart';
import 'package:sugar_production/features/sync/screens/sync.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class AppDrawer extends StatelessWidget {
  final dynamic user;
  final String firstName;
  final String initial;
  final bool isDark;
  final VoidCallback? onClearData;

  const AppDrawer({
    super.key,
    required this.user,
    required this.firstName,
    required this.initial,
    required this.isDark,
    this.onClearData,
  });

  PageRoute _route(Widget page) => MaterialPageRoute(builder: (_) => page);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.appColors.surface,
      width: 285,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────
          _DrawerHeader(initial: initial, firstName: firstName, user: user),

          const SizedBox(height: 16),

          // Section label
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MENU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textHint,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),

          _DrawerItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, _route(NotificationsScreen()));
            },
          ),
          _DrawerItem(
            icon: Icons.sync_rounded,
            label: 'Synchronization',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, _route(SyncScreen()));
            },
          ),

          _Divider(),

          // ── Theme toggle ──────────────────────────────
          _ThemeToggleTile(isDark: isDark),

          _Divider(),

          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: AppTheme.accentRed,
            isDark: isDark,
            onTap: () {
              AuthService().logout();
              Navigator.pushReplacement(context, _route(LoginScreen()));
            },
          ),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Sugar Production  •  v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: context.appColors.textHint,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Header ────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final dynamic user;
  final String firstName;
  final String initial;

  const _DrawerHeader({
    required this.user,
    required this.firstName,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 28,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(gradient: context.gradients.header),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            firstName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
                width: 1,
              ),
            ),
            child: Text(
              'ID: ${user?.usernameid?.toString() ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Item ───────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          splashColor: color.withOpacity(0.10),
          highlightColor: color.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color == AppTheme.primary
                          ? context.appColors.textPrimary
                          : color,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: color.withOpacity(0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme Toggle Tile ─────────────────────────────────────────────

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          // onTap: () => themeNotifier.toggle(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        isDark ? 'Dark mode' : 'Light mode',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated pill toggle
                GestureDetector(
                  // onTap: () => themeNotifier.toggle(context),
                  child: Container(
                    width: 46,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: isDark ? AppTheme.primaryGradient : null,
                      color: isDark ? null : colors.border,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: isDark
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 11,
                              color: isDark
                                  ? AppTheme.primary
                                  : colors.textHint,
                            ),
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
      ),
    );
  }
}

// ── Divider helper ────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(color: context.appColors.border, thickness: 1, height: 1),
    );
  }
}
