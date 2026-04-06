import 'package:flutter/material.dart';
import 'package:sugar_production/models/modnotif.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// Notification List Item
// ─────────────────────────────────────────────
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final Notifications notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDark;
    final n = notification;

    final String datetime = n.notifdatetime;
    final String date = datetime.contains(' ')
        ? datetime.split(' ').first
        : datetime;
    final String time = datetime.contains(' ') ? datetime.split(' ').last : '';
    final bool isUnread = n.traflag == 0;

    final cardColor = isUnread
        ? (isDark
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.primary.withOpacity(0.06))
        : colors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(
              color: isUnread
                  ? AppTheme.primary.withOpacity(0.25)
                  : colors.border,
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: AppTheme.shadowSM(dark: isDark),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUnread)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 8),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        n.notiftitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: colors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  n.notifbody,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.textSecondary,
                    height: 1.5,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: colors.border),
                const SizedBox(height: 10),
                // Date/time row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: colors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.textHint,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: colors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────
class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 36,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 13, color: colors.textHint),
          ),
        ],
      ),
    );
  }
}
