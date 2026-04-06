import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/models/modcpr.dart';
import '../controllers/statistics_controller.dart';
import '../widgets/statistics_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'package:sugar_production/features/sync/controllers/sync_controller.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.onCprTap});

  final void Function(CPR)? onCprTap;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final StatisticsController _ctrl;
  final _syncCtrl = SyncController();

  @override
  void initState() {
    super.initState();
    _ctrl = StatisticsController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _syncCtrl.dispose();
    super.dispose();
  }

  Future<void> _tapLatestCpr() async {
    final refno = _ctrl.latestCPR?[colccprrefno]?.toString();
    if (refno == null || widget.onCprTap == null) return;
    final map = await CprService.getCprByCode(refno);
    if (map == null || !mounted) return;
    widget.onCprTap!(CPR.fromMapObject(map));
  }

  Future<void> _showSyncPicker() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.sync_rounded,
              color: AppTheme.accentAmber,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Sync ${_ctrl.unsyncedCPR} Pending CPR${_ctrl.unsyncedCPR > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSyncButton(
              ctx,
              icon: Icons.wifi_rounded,
              label: 'Local Network',
              subtitle: 'Sync via local WiFi',
              conntype: 2,
            ),
            const SizedBox(height: 10),
            _buildSyncButton(
              ctx,
              icon: Icons.cloud_outlined,
              label: 'Internet',
              subtitle: 'Sync via internet',
              conntype: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String subtitle,
    required int conntype,
  }) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        onTap: () {
          Navigator.of(ctx).pop();
          _runSync(conntype);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runSync(int conntype) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            _syncCtrl.addListener(() {
              if (ctx.mounted) setDialogState(() {});
            });
            // return _SyncProgressDialog(
            //   progress: _syncCtrl.progress,
            //   statusText: _syncCtrl.statusText,
            // );
            return Dialog(
              backgroundColor: context.appColors.surface,
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
                        const Icon(
                          Icons.sync,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Syncronizing',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_syncCtrl.progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _syncCtrl.progress,
                        minHeight: 6,
                        backgroundColor: context.appColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _syncCtrl.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    try {
      final success = await _syncCtrl.sync(context, conntype);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showResult(success);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showResult(false, message: 'Error: $e');
    }
  }

  void _showResult(bool success, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        title: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: success ? AppTheme.primary : AppTheme.accentRed,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              success ? 'Sync Complete' : 'Sync Failed',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          message ??
              (success
                  ? 'CPR records synchronized successfully.'
                  : 'Synchronization failed. Please try again.'),
          style: TextStyle(
            fontSize: 13,
            color: context.appColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: success ? AppTheme.primary : AppTheme.accentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colors.background,
      body: _ctrl.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5,
              ),
            )
          : Stack(
              children: [
                Container(height: 30, color: AppTheme.primary),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: RefreshIndicator(
                      onRefresh: _ctrl.loadStats,
                      color: AppTheme.primary,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          24 + bottomPadding,
                        ),
                        children: [
                          const StatsSectionLabel('OVERVIEW'),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.receipt_long_rounded,
                                  label: 'Total Requests',
                                  value: _ctrl.totalRequests.toString(),
                                  accent: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.grass_rounded,
                                  label: 'Total Planters',
                                  value: _ctrl.totalPlanters.toString(),
                                  accent: const Color(0xFF0EA5E9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.local_shipping_rounded,
                                  label: 'Total CPR',
                                  value: _ctrl.totalCPR.toString(),
                                  accent: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.cloud_done_rounded,
                                  label: 'Synced CPR',
                                  value: _ctrl.syncedCPR.toString(),
                                  accent: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // UnsyncedCard(unsyncedCount: _ctrl.unsyncedCPR),
                          UnsyncedCard(
                            unsyncedCount: _ctrl.unsyncedCPR,
                            onsync: _ctrl.unsyncedCPR > 0
                                ? _showSyncPicker
                                : null,
                          ),
                          const SizedBox(height: 20),

                          const StatsSectionLabel('LATEST CPR'),
                          const SizedBox(height: 10),

                          LatestCPRCard(
                            latestCPR: _ctrl.latestCPR,
                            formattedDate: _ctrl.formatDate(
                              _ctrl.latestCPR?[colcprdatedelivered]?.toString(),
                            ),
                            onTap: _ctrl.latestCPR != null
                                ? _tapLatestCpr
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
