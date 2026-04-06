import 'package:flutter/material.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// CPR List
// ─────────────────────────────────────────────
class CprList extends StatelessWidget {
  const CprList({
    super.key,
    required this.cprs,
    required this.onRefresh,
    required this.onTap,
    required this.formatDate,
  });

  final List<CPR> cprs;
  final Future<void> Function() onRefresh;
  final void Function(CPR) onTap;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: cprs.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CprItem(
            cpr: cprs[index],
            onTap: onTap,
            formatDate: formatDate,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CPR Item Card
// ─────────────────────────────────────────────
class CprItem extends StatelessWidget {
  const CprItem({
    super.key,
    required this.cpr,
    required this.onTap,
    required this.formatDate,
  });

  final CPR cpr;
  final void Function(CPR) onTap;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isSynced = cpr.traflag == 'S';
    final syncColor = isSynced ? AppTheme.primary : AppTheme.accentAmber;

    return FutureBuilder<Map<String, String>>(
      future: CprService.getcprDetails(cpr),
      builder: (context, snapshot) {
        final planterName = snapshot.data?['planterName'] ?? '...';
        final requestNumber = snapshot.data?['requestNumber'] ?? '...';
        final isLoaded = snapshot.hasData;

        return Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            splashColor: AppTheme.primary.withOpacity(0.05),
            onTap: () => onTap(cpr),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                border: Border.all(color: colors.border, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CPR-${cpr.colccprrefno}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatDate(cpr.colcprdatedelivered),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _SyncBadge(isSynced: isSynced, syncColor: syncColor),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(height: 1, color: colors.border),
                  const SizedBox(height: 12),

                  // ── Info chips ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CprInfoChip(
                          icon: Icons.person_rounded,
                          label: 'Planter',
                          value: isLoaded ? planterName : '—',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: CprInfoChip(
                          icon: Icons.tag_rounded,
                          label: 'Request #',
                          value: isLoaded ? requestNumber : '—',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Stats bar ────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CprStatItem(
                            label: 'Quantity',
                            value: cpr.colcprqty.toString(),
                            valueColor: AppTheme.primary,
                          ),
                        ),
                        Container(width: 1, height: 32, color: colors.border),
                        Expanded(
                          child: CprStatItem(
                            label: 'Print Count',
                            value: cpr.colcprcounter?.toString() ?? '0',
                            valueColor: colors.textSecondary,
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
      },
    );
  }
}

// ─────────────────────────────────────────────
// Sync Badge (private to this file)
// ─────────────────────────────────────────────
class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.isSynced, required this.syncColor});

  final bool isSynced;
  final Color syncColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: syncColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
            size: 12,
            color: syncColor,
          ),
          const SizedBox(width: 4),
          Text(
            isSynced ? 'Synced' : 'Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: syncColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info Chip
// ─────────────────────────────────────────────
class CprInfoChip extends StatelessWidget {
  const CprInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: colors.textHint),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Stat Item
// ─────────────────────────────────────────────
class CprStatItem extends StatelessWidget {
  const CprStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
