import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// Sync Option Row
// ─────────────────────────────────────────────
class SyncOption extends StatelessWidget {
  const SyncOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDisabled = onTap == null;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        splashColor: AppTheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              isDisabled
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: colors.textHint,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Syncing Progress Dialog
// ─────────────────────────────────────────────
class SyncingDialog extends StatelessWidget {
  const SyncingDialog({
    super.key,
    required this.progress,
    required this.statusText,
  });

  final double progress;
  final String statusText;

  static void show(
    BuildContext context, {
    required Stream<(double, String)> stream,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: StreamBuilder<(double, String)>(
          stream: stream,
          builder: (ctx, snapshot) => SyncingDialog(
            progress: snapshot.data?.$1 ?? 0.0,
            statusText: snapshot.data?.$2 ?? 'Connecting...',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, color: AppTheme.primary, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Synchronizing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Please do not close the application',
              style: TextStyle(fontSize: 12, color: colors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sync Result Dialog
// ─────────────────────────────────────────────
class SyncResultDialog extends StatelessWidget {
  const SyncResultDialog({
    super.key,
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  static void show(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SyncResultDialog(success: success, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = success ? AppTheme.primary : AppTheme.accentRed;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: accent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  success ? 'Sync Complete' : 'Sync Failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: success ? AppTheme.primaryGradient : null,
                  color: success ? null : AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
