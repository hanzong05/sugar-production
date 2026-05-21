import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'package:sugar_production/core/services/update_service.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'dart:async';

class ProfilepageScreen extends StatefulWidget {
  const ProfilepageScreen({super.key});

  @override
  State<ProfilepageScreen> createState() => _ProfilepageScreenState();
}

class _ProfilepageScreenState extends State<ProfilepageScreen> {
  late final ProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ProfileController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final user = AuthService().currentUser;
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
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        24 + bottomPadding,
                      ),
                      children: [
                        // ── User Banner ───────────────────────────
                        UserBanner(user: user),

                        const SizedBox(height: 20),

                        // ── Sync Overview ─────────────────────────
                        const ProfileSectionLabel('SYNC OVERVIEW'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileStatCard(
                                icon: Icons.cloud_off_rounded,
                                value: _ctrl.unsyncedCount.toString(),
                                label: 'Unsynced CPR',
                                accent: _ctrl.unsyncedCount > 0
                                    ? AppTheme.accentAmber
                                    : AppTheme.primary,
                                badge: _ctrl.unsyncedCount > 0
                                    ? 'Needs Sync'
                                    : 'Up to date',
                                badgeOk: _ctrl.unsyncedCount == 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ProfileStatCard(
                                icon: Icons.receipt_long_rounded,
                                value: _ctrl.totalCount.toString(),
                                label: 'Total CPR',
                                accent: AppTheme.primary,
                                badge: 'All time',
                                badgeOk: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Account ───────────────────────────────
                        const ProfileSectionLabel('ACCOUNT'),
                        const SizedBox(height: 10),
                        ProfileInfoCard(user: user),

                        const SizedBox(height: 20),

                        // ── Sign Out ──────────────────────────────
                        // const SignOutButton(),
                        const SizedBox(height: 20),

                        const ProfileSectionLabel('APP INFO'),
                        const SizedBox(height: 10),

                        AppVersionCard(
                          currentVersion: _ctrl.appVersion,
                          latestVersion: _ctrl.latestVersion.isEmpty
                              ? _ctrl.appVersion
                              : _ctrl.latestVersion,
                          hasUpdate: _ctrl.hasUpdate,
                          checkingUpdate:
                              _ctrl.checkingUpdate, // pass loading state
                          onCheckUpdate: () =>
                              _ctrl.checkForUpdate(), // ← add this
                          onUpdate: () async {
                            final progressController =
                                StreamController<(double, int, int)>();

                            DownloadProgressDialog.show(
                              context,
                              stream: progressController.stream,
                            );

                            await updateVersion(
                              _ctrl.apkUrl,
                              onProgress: (progress, received, total) {
                                if (!progressController.isClosed) {
                                  progressController.add((
                                    progress,
                                    received,
                                    total,
                                  ));
                                }
                              },
                            );

                            progressController.close();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
