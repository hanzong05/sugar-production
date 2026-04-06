import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'package:sugar_production/core/services/notification.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const AppHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          gradient: context.gradients.header,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Centered title ───────────────────────────────
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // ── Left: Back button (optional) ─────────────────
                if (showBackButton)
                  Positioned(
                    left: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onBackTap ?? () => Navigator.pop(context),
                    ),
                  ),

                // ── Right: Notification bell ─────────────────────
                Positioned(
                  right: 16,
                  child: ValueListenableBuilder<int>(
                    valueListenable: NotificationUtils.unreadCountNotifier,
                    builder: (context, count, _) {
                      return GestureDetector(
                        onTap: onNotificationTap,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    constraints: const BoxConstraints(
                                      minHeight: 14,
                                      minWidth: 14,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentRed,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      count > 99 ? '99+' : '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
