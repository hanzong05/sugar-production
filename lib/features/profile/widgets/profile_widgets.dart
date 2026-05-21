import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// User Identity Banner
// ─────────────────────────────────────────────
class UserBanner extends StatelessWidget {
  const UserBanner({super.key, required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final initial = (user?.fullname ?? 'U')
        .trim()
        .split(' ')
        .first[0]
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.shadowBrand(dark: context.isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullname ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '@${user?.username ?? 'nouser'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(this.text, {super.key});

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
// Stat Card
// ─────────────────────────────────────────────
class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.badge,
    required this.badgeOk,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final String badge;
  final bool badgeOk;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final badgeBg = badgeOk
        ? AppTheme.primary.withOpacity(0.10)
        : AppTheme.accentAmber.withOpacity(0.12);
    final badgeText = badgeOk ? AppTheme.primary : AppTheme.accentAmber;

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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: accent,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusXS),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info Card (Full Name / Username / Role)
// ─────────────────────────────────────────────
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: colors.border),
        boxShadow: AppTheme.shadowSM(dark: context.isDark),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: user?.fullname ?? '—',
          ),
          Divider(height: 1, indent: 52, color: colors.border),
          _InfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Username',
            value: '@${user?.username ?? '—'}',
          ),
          Divider(height: 1, indent: 52, color: colors.border),
          const _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: 'Field Operator',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, size: 17, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// App Version Container
// ─────────────────────────────────────────────
class AppVersionCard extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final bool checkingUpdate;
  final VoidCallback onCheckUpdate;
  final Future<void> Function() onUpdate;

  const AppVersionCard({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.checkingUpdate,
    required this.onCheckUpdate,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                'Version $currentVersion',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // ── Check for Updates button ──
              if (!hasUpdate)
                checkingUpdate
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton.icon(
                        onPressed: onCheckUpdate,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Check'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
            ],
          ),
          if (hasUpdate) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.system_update_rounded,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 6),
                Text(
                  'v$latestVersion available',
                  style: const TextStyle(color: Colors.amber),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onUpdate,
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Download Progress Dialog
// ─────────────────────────────────────────────
class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({
    super.key,
    required this.progress,
    required this.received,
    required this.total,
  });

  final double progress;
  final int received;
  final int total;

  static void show(
    BuildContext context, {
    required Stream<(double, int, int)> stream,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: StreamBuilder<(double, int, int)>(
          stream: stream,
          builder: (ctx, snapshot) {
            // ── Auto-close when stream is done ──
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(ctx).canPop()) {
                  Navigator.of(ctx).pop();
                }
              });
            }

            // ── Error state ──
            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(ctx).canPop()) {
                  Navigator.of(ctx).pop();
                }
              });
            }

            return DownloadProgressDialog(
              progress: snapshot.data?.$1 ?? 0.0,
              received: snapshot.data?.$2 ?? 0,
              total: snapshot.data?.$3 ?? 0,
            );
          },
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = (progress * 100).toInt();
    final isIndeterminate = total <= 0;

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
            // ── Header ──
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Downloading Update',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'app-release.apk',
                        style: TextStyle(fontSize: 11, color: colors.textHint),
                      ),
                    ],
                  ),
                ),
                Text(
                  isIndeterminate ? '...' : '$percent%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Progress Bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: isIndeterminate ? null : progress,
                minHeight: 8,
                backgroundColor: colors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Size Info ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isIndeterminate
                      ? 'Preparing download...'
                      : '${_formatBytes(received)} / ${_formatBytes(total)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isIndeterminate)
                  Text(
                    _formatBytes(total),
                    style: TextStyle(fontSize: 12, color: colors.textHint),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Footer ──
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: colors.textHint,
                ),
                const SizedBox(width: 5),
                Text(
                  'Please do not close the application',
                  style: TextStyle(fontSize: 11, color: colors.textHint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
// Sign Out Button
// ─────────────────────────────────────────────
// class SignOutButton extends StatelessWidget {
//   const SignOutButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: () async => await AuthService().logout(),
//       icon: const Icon(Icons.logout_rounded, size: 17),
//       label: const Text('Sign Out'),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppTheme.accentRed,
//         side: BorderSide(
//           color: AppTheme.accentRed.withOpacity(0.40),
//           width: 1.5,
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 13),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//         ),
//         textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
//       ),
//     );
//   }
// }
