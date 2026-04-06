import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────
class StatsSectionLabel extends StatelessWidget {
  const StatsSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: context.appColors.textHint,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stat Card (icon + value + label)
// ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: colors.border),
        boxShadow: AppTheme.shadowSM(dark: context.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: accent,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Unsynced CPR Card
// ─────────────────────────────────────────────
class UnsyncedCard extends StatelessWidget {
  // const UnsyncedCard({super.key, required this.unsyncedCount});
  const UnsyncedCard({super.key, required this.unsyncedCount, this.onsync});

  final int unsyncedCount;
  final VoidCallback? onsync;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasUnsynced = unsyncedCount > 0;
    final accent = hasUnsynced ? AppTheme.accentAmber : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: hasUnsynced
              ? AppTheme.accentAmber.withOpacity(0.35)
              : colors.border,
        ),
        boxShadow: AppTheme.shadowSM(dark: context.isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(
              hasUnsynced
                  ? Icons.cloud_upload_rounded
                  : Icons.cloud_done_rounded,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unsynced CPR',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasUnsynced
                      ? '$unsyncedCount record${unsyncedCount > 1 ? 's' : ''} pending upload'
                      : 'All records are synced',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (hasUnsynced && onsync != null) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: onsync,
              icon: const Icon(Icons.sync_rounded),
              color: AppTheme.accentAmber,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accentAmber.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
            ),
          ] else ...[
            Text(
              unsyncedCount.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: accent,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Latest CPR Card
// ─────────────────────────────────────────────
class LatestCPRCard extends StatelessWidget {
  const LatestCPRCard({
    super.key,
    required this.latestCPR,
    required this.formattedDate,
    this.onTap,
  });

  final Map<String, dynamic>? latestCPR;
  final String formattedDate;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (latestCPR == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: colors.border),
        ),
        child: Center(
          child: Text(
            'No CPR records yet',
            style: TextStyle(
              fontSize: 13,
              color: colors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final refno = latestCPR![colccprrefno]?.toString() ?? '—';
    final qty = latestCPR![colcprqty]?.toString() ?? '—';
    final planter = latestCPR![colPlname]?.toString() ?? '—';
    final isSynced = latestCPR![colcprtraflag] == 'S';
    final syncColor = isSynced ? AppTheme.primary : AppTheme.accentAmber;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        splashColor: AppTheme.primary.withOpacity(0.05),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: colors.border),
            boxShadow: AppTheme.shadowSM(dark: context.isDark),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: const Icon(
                        Icons.receipt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CPR-$refno',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            planter,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sync badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: syncColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSynced
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_upload_rounded,
                            size: 11,
                            color: syncColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSynced ? 'Synced' : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: syncColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: colors.border),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.grass_rounded,
                        label: 'Quantity',
                        value: qty,
                        valueColor: AppTheme.primary,
                      ),
                    ),
                    Container(width: 1, height: 32, color: colors.border),
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: formattedDate,
                        valueColor: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mini Stat (icon + value + label)
// ─────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 13, color: valueColor.withOpacity(0.65)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
