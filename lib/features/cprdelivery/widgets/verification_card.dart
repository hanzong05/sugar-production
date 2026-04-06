import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// Verification Card
// ─────────────────────────────────────────────
class VerificationCard extends StatelessWidget {
  const VerificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isComplete,
    required this.onTap,
    this.onPreview,
    this.preview,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isComplete;
  final VoidCallback onTap;
  final VoidCallback? onPreview;
  final Widget? preview;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasAsterisk = title.endsWith(' *');
    final base = hasAsterisk ? title.substring(0, title.length - 2) : title;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: InkWell(
        borderRadius: preview != null
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : BorderRadius.circular(AppTheme.radiusLG),
        splashColor: AppTheme.primary.withOpacity(0.05),
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(
              color: isComplete
                  ? AppTheme.primary.withOpacity(0.4)
                  : colors.border,
              width: isComplete ? 1.5 : 1,
            ),
            boxShadow: AppTheme.shadowSM(dark: context.isDark),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isComplete ? AppTheme.primaryGradient : null,
                        color: isComplete ? null : colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isComplete ? Colors.white : colors.textHint,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: base,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isComplete
                                    ? AppTheme.primary
                                    : colors.textPrimary,
                              ),
                              children: hasAsterisk
                                  ? [
                                      const TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onPreview != null) ...[
                      GestureDetector(
                        onTap: enabled ? onPreview : null,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: const Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isComplete
                            ? AppTheme.primary.withOpacity(0.10)
                            : colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Icon(
                        isComplete
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: isComplete ? 16 : 13,
                        color: isComplete ? AppTheme.primary : colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              if (preview != null) ...[
                Divider(
                  height: 1,
                  color: isComplete
                      ? AppTheme.primary.withOpacity(0.15)
                      : colors.border,
                ),
                preview!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Preview Dialog
// ─────────────────────────────────────────────
class PreviewDialog extends StatelessWidget {
  const PreviewDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    required this.onRedo,
    this.redoLabel = 'Redo',
    this.redoIcon = Icons.refresh_rounded,
    this.tall = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onRedo;
  final String redoLabel;
  final IconData redoIcon;
  final bool tall;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    required VoidCallback onRedo,
    String redoLabel = 'Redo',
    IconData redoIcon = Icons.refresh_rounded,
    bool tall = false,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PreviewDialog(
        title: title,
        icon: icon,
        onRedo: onRedo,
        redoLabel: redoLabel,
        redoIcon: redoIcon,
        tall: tall,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: AppTheme.shadowLG(dark: context.isDark),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: tall ? 380 : 280),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: colors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: child,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRedo,
                    icon: Icon(redoIcon, size: 16),
                    label: Text(redoLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
