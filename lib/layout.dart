import 'dart:async';
import 'package:flutter/material.dart';
import 'features/homepage/screens/homepage.dart';
import 'features/profile/screens/profile.dart';
import 'features/sync/screens/sync.dart';
import 'features/cprdelivery/screens/planters.dart';
import 'features/cprdelivery/screens/requests.dart';
import 'features/cprdelivery/screens/seed_delivery.dart';
import 'features/cprhistory/screens/cpr_history.dart';
import 'features/cprhistory/screens/cpr_info.dart';
import 'features/lotpictures/screens/landprep_form.dart';
import 'features/notifications/screens/notification.dart';
import 'features/statistics/screens/statistics.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/core/services/notification.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'package:sugar_production/main.dart' show themeNotifier;
import 'package:sugar_production/features/homepage/widgets/bottom_navigation.dart';
import 'package:sugar_production/features/homepage/widgets/app_header.dart';

const int kIndexSync = 0;
const int kIndexHome = 1;
const int kIndexProfile = 2;
const int kIndexCPR = 3;
const int kIndexHistory = 4;
const int kIndexPlanterReq = 5;
const int kIndexCPRForm = 6;
const int kIndexCPRInfo = 7;
const int kIndexNotifications = 8;
const int kIndexStatistics = 9;
const int kIndexLotPictures = 10;

// ─── Navigation mode ─────────────────────────────────────────────────────────
/// Tells shared screens (planter list, requests) which form to open.
enum NavMode { cprDelivery, lotPictures }

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  AppLayoutState createState() => AppLayoutState();
}

class AppLayoutState extends State<AppLayout> {
  final GlobalKey<PlanterScreenState> _cprKey = GlobalKey<PlanterScreenState>();

  int _selectedIndex = kIndexHome;
  Planter? _selectedPlanter;
  Map<String, dynamic>? _selectedRequest;
  CPR? _selectedCPR;

  /// Current navigation mode — determines which form opens after request tap.
  NavMode _navMode = NavMode.cprDelivery;

  List<Widget> get _screens => [
    SyncScreen(), // 0
    HomePage(), // 1
    ProfilepageScreen(), // 2
    PlanterScreen(key: _cprKey), // 3
    CprsHistory(onCprTap: (cpr) => navigateToCPRInfo(cpr)), // 4
    // 5 – Planter list: same widget for both modes
    if (_selectedPlanter != null)
      PlanterReqScreen(
        key: ValueKey(_selectedPlanter!.plid),
        planter: _selectedPlanter!,
      )
    else
      const SizedBox(),
    // 6 – Form: branch on navMode
    if (_selectedRequest != null && _selectedPlanter != null)
      _navMode == NavMode.cprDelivery
          ? SeedDeliveryForm(
              key: ValueKey(
                'cpr_${_selectedRequest!['request_id']}_${_selectedPlanter!.plid}',
              ),
              request: _selectedRequest!,
              planter: _selectedPlanter!,
              onSubmitSuccess: () => navigateTo(kIndexPlanterReq),
            )
          : LandPrepVerificationForm(
              key: ValueKey(
                'lp_${_selectedRequest!['request_id']}_${_selectedPlanter!.plid}',
              ),
              request: _selectedRequest!,
              planter: _selectedPlanter!,
              onSubmitSuccess: () => navigateTo(kIndexPlanterReq),
            )
    else
      const SizedBox(),
    if (_selectedCPR != null)
      CprInfo(cpr: _selectedCPR!)
    else
      const SizedBox(), // 7
    const NotificationsScreen(), // 8
    StatisticsScreen(onCprTap: (cpr) => navigateToCPRInfo(cpr)), // 9
  ];

  final List<String> _titles = [
    'Sync',
    'Home',
    'Profile',
    'Cane Points Delivery',
    'CPR Records',
    'Planter Requests',
    'Receive Seeds', // overridden below for lot-pictures mode
    'CPR Details',
    'Notifications',
    'Statistics',
  ];

  /// Title shown in the app bar for kIndexCPRForm — changes with mode.
  String get _formTitle =>
      _navMode == NavMode.lotPictures ? 'CP Lot Pictures' : 'Receive Seeds';

  /// Title shown in the app bar for kIndexPlanterReq — changes with mode.
  String get _planterReqTitle => _navMode == NavMode.lotPictures
      ? 'Planter Requests (Lot Pictures)'
      : 'Planter Requests';

  final List<IconData> _outlineIcons = [
    Icons.sync_outlined,
    Icons.home_outlined,
    Icons.person_outline_rounded,
  ];

  final List<IconData> _filledIcons = [
    Icons.sync_rounded,
    Icons.home_rounded,
    Icons.person_rounded,
  ];

  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChanged);

    FlutterBackgroundService().on('newNotification').listen((_) async {
      await NotificationUtils.checkPendingOnResume();
      await NotificationUtils.refreshUnreadcount();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      NotificationUtils.handleAppLaunch();
      await Future.delayed(const Duration(milliseconds: 800));
      await NotificationUtils.checkPendingOnResume();
      await NotificationUtils.refreshUnreadcount();
    });

    _notifTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      NotificationUtils.checkPendingOnResume();
    });
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _notifTimer?.cancel();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    if (index == kIndexCPR) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cprKey.currentState?.reload();
      });
    }
  }

  void navigateTo(int index) {
    setState(() => _selectedIndex = index);
    if (index == kIndexCPR) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cprKey.currentState?.reload();
      });
    }
  }

  void navigateToPlanter(Planter planter) {
    setState(() {
      _selectedPlanter = planter;
      _selectedIndex = kIndexPlanterReq;
    });
  }

  /// Navigate to CPR Delivery flow (existing behaviour).
  void navigateToCPRDelivery() {
    setState(() {
      _navMode = NavMode.cprDelivery;
      _selectedIndex = kIndexCPR;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cprKey.currentState?.reload();
    });
  }

  /// Navigate to Lot Pictures flow — opens same planter list but branches to
  /// [LandPrepVerificationForm] when a request is tapped.
  void navigateToLotPictures() {
    setState(() {
      _navMode = NavMode.lotPictures;
      _selectedIndex = kIndexCPR; // reuse same planter-list screen
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cprKey.currentState?.reload();
    });
  }

  void navigateToCPRForm(Map<String, dynamic> request, Planter planter) {
    setState(() {
      _selectedRequest = request;
      _selectedPlanter = planter;
      _selectedIndex = kIndexCPRForm;
    });
  }

  void navigateToCPRInfo(CPR cpr) {
    setState(() {
      _selectedCPR = cpr;
      _selectedIndex = kIndexCPRInfo;
    });
  }

  void navigateToNotifications() {
    setState(() => _selectedIndex = kIndexNotifications);
  }

  bool get _isSubScreen =>
      _selectedIndex == kIndexCPR ||
      _selectedIndex == kIndexHistory ||
      _selectedIndex == kIndexPlanterReq ||
      _selectedIndex == kIndexCPRForm ||
      _selectedIndex == kIndexCPRInfo ||
      _selectedIndex == kIndexStatistics;

  // ─── Helper: format date short ────────────────────────────────────────────────
  String _fmtDateShort(String? s) {
    if (s == null || s.isEmpty) return '—';
    try {
      final dt = DateTime.parse(s);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${m[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return s;
    }
  }

  // ─── Shared: floating stats card ─────────────────────────────────────────────
  Widget _buildFloatingStatsCard(BuildContext context, List<_StatEntry> stats) {
    return Positioned(
      bottom: -46,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.14),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              Expanded(
                child: _buildHeaderStat(
                  context,
                  icon: stats[i].icon,
                  label: stats[i].label,
                  value: stats[i].value,
                  valueColor: stats[i].valueColor,
                ),
              ),
              if (i < stats.length - 1)
                Container(
                  width: 1,
                  height: 36,
                  color: context.appColors.border,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: valueColor.withOpacity(0.65)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor,
            letterSpacing: -0.3,
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

  // ─── CPR Info App Bar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildCPRInfoAppBar(BuildContext context) {
    final cpr = _selectedCPR;
    final isSynced = cpr?.traflag == 'S';
    final syncColor = isSynced
        ? Colors.greenAccent.shade200
        : AppTheme.accentAmber;

    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: context.gradients.header,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 30),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => navigateTo(kIndexHistory),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CPR Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          if (cpr?.colccprrefno != null)
                            Text(
                              'CPR-${cpr!.colccprrefno}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.30),
                          width: 1,
                        ),
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
            ),
          ),
          _buildFloatingStatsCard(context, [
            _StatEntry(
              icon: Icons.grass_rounded,
              label: 'Quantity',
              value: cpr?.colcprqty?.toString() ?? '—',
              valueColor: AppTheme.primary,
            ),
            _StatEntry(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: _fmtDateShort(cpr?.colcprdatedelivered),
              valueColor: context.appColors.textPrimary,
            ),
            _StatEntry(
              icon: Icons.print_rounded,
              label: 'Prints',
              value: cpr?.colcprcounter?.toString() ?? '0',
              valueColor: context.appColors.textSecondary,
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Planter Req App Bar ──────────────────────────────────────────────────────
  PreferredSizeWidget _buildPlanterReqAppBar(BuildContext context) {
    final planter = _selectedPlanter;
    final name = planter?.plname ?? 'Unknown Planter';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final code = planter?.plcode ?? '—';

    // Badge changes colour & label depending on active flow
    final isLotMode = _navMode == NavMode.lotPictures;
    final modeBadgeColor = isLotMode
        ? AppTheme.accentAmber
        : Colors.greenAccent.shade200;
    final modeBadgeLabel = isLotMode ? 'Lot Pictures' : 'CPR Delivery';
    final modeBadgeIcon = isLotMode
        ? Icons.photo_library_rounded
        : Icons.local_shipping_rounded;

    return PreferredSize(
      preferredSize: const Size.fromHeight(130),
      child: Container(
        decoration: BoxDecoration(
          gradient: context.gradients.header,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => navigateTo(kIndexCPR),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.50),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // ── Mode badge ──────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.40),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  modeBadgeIcon,
                                  size: 10,
                                  color: modeBadgeColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  modeBadgeLabel,
                                  style: TextStyle(
                                    color: modeBadgeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAppBarStat(
                          icon: Icons.tag_rounded,
                          label: 'Code',
                          value: code,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildAppBarStat(
                          icon: Icons.grass_rounded,
                          label: 'Type',
                          value: 'Planter',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildAppBarStat(
                          icon: Icons.person_rounded,
                          label: 'Initial',
                          value: initial,
                          color: Colors.white,
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CPR Screen App Bar (shared by CPR + History) ─────────────────────────────
  PreferredSizeWidget _buildGreenAppBar({
    required BuildContext context,
    required String title,
    required VoidCallback onBack,
    required IconData titleIcon,
    IconData? highlightIcon,
    String? highlightLabel,
    String? highlightDescription,
    VoidCallback? highlightOnTap,
    bool showQuickCards = true,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(showQuickCards ? 250 : 60),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onBack,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Icon(titleIcon, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    // ── Mode pill next to title ────────────────────
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_navMode == NavMode.lotPictures) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.accentAmber.withOpacity(0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.photo_library_rounded,
                                    size: 10,
                                    color: AppTheme.accentAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lot Pictures',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (showQuickCards) ...[
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildQuickCard(
                            context,
                            icon: Icons.bar_chart_rounded,
                            label: 'Statistics',
                            description: 'View production reports.',
                            highlight: false,
                            onTap: () => navigateTo(kIndexStatistics),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickCard(
                            context,
                            icon: highlightIcon!,
                            label: highlightLabel!,
                            description: highlightDescription!,
                            highlight: true,
                            onTap: highlightOnTap!,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQuickCard(
                    context,
                    icon: Icons.person_rounded,
                    label: 'View Profile',
                    description: 'Manage your account.',
                    highlight: false,
                    onTap: () => navigateTo(kIndexProfile),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CPR Form App Bar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildCPRFormAppBar(BuildContext context) {
    final planter = _selectedPlanter;
    final request = _selectedRequest;
    final name = planter?.plname ?? 'Unknown Planter';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final requestNo = request?['request_no']?.toString() ?? 'N/A';
    final totalQty = request?['total_qty'] ?? 0;
    final deliveredQty = request?['delivered_qty'] ?? 0;
    final remaining = (totalQty - deliveredQty).toString();
    final isLotMode = _navMode == NavMode.lotPictures;

    return PreferredSize(
      preferredSize: const Size.fromHeight(130),
      child: Container(
        decoration: BoxDecoration(
          gradient: context.gradients.header,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => navigateTo(kIndexPlanterReq),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.50),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.40),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLotMode
                                      ? Icons.photo_library_rounded
                                      : Icons.receipt_long_rounded,
                                  size: 10,
                                  color: isLotMode
                                      ? AppTheme.accentAmber
                                      : Colors.white.withOpacity(0.85),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isLotMode
                                      ? 'Lot Pictures'
                                      : 'Req #$requestNo',
                                  style: TextStyle(
                                    color: isLotMode
                                        ? AppTheme.accentAmber
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAppBarStat(
                          icon: Icons.inventory_2_rounded,
                          label: 'Req',
                          value: '$totalQty',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildAppBarStat(
                          icon: Icons.check_circle_rounded,
                          label: 'Done',
                          value: '$deliveredQty',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildAppBarStat(
                          icon: Icons.hourglass_bottom_rounded,
                          label: 'Left',
                          value: remaining,
                          color: Colors.white,
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.white.withOpacity(0.22)
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? Colors.white.withOpacity(0.55)
              : Colors.white.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 11,
            color: color.withOpacity(highlight ? 1.0 : 0.75),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$value $label',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Notifications App Bar ───────────────────────────────────────────────────
  PreferredSizeWidget _buildNotificationsAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          gradient: context.gradients.header,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => navigateTo(kIndexHome),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isLotMode = _navMode == NavMode.lotPictures;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == kIndexCPRForm) {
          navigateTo(kIndexPlanterReq);
          return false;
        } else if (_selectedIndex == kIndexPlanterReq) {
          navigateTo(kIndexCPR);
          return false;
        } else if (_selectedIndex == kIndexCPRInfo) {
          navigateTo(kIndexHistory);
          return false;
        } else if (_selectedIndex == kIndexHistory) {
          navigateTo(kIndexHome);
          return false;
        } else if (_selectedIndex == kIndexCPR) {
          navigateTo(kIndexHome);
          return false;
        } else if (_selectedIndex == kIndexStatistics) {
          navigateTo(kIndexHome);
          return false;
        } else if (_selectedIndex == kIndexNotifications) {
          navigateTo(kIndexHome);
          return false;
        }

        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: context.appColors.background,
        appBar: _selectedIndex == kIndexCPR
            ? _buildGreenAppBar(
                context: context,
                title: isLotMode ? 'CP Lot Pictures' : 'Cane Points Delivery',
                titleIcon: isLotMode
                    ? Icons.photo_library_rounded
                    : Icons.local_shipping_rounded,
                onBack: () => navigateTo(kIndexHome),
                highlightIcon: Icons.history_rounded,
                highlightLabel: 'CPR History',
                highlightDescription: 'Browse delivery records.',
                highlightOnTap: () => navigateTo(kIndexHistory),
              )
            : _selectedIndex == kIndexHistory
            ? _buildGreenAppBar(
                context: context,
                title: 'CPR Records',
                titleIcon: Icons.history_rounded,
                onBack: () => navigateTo(kIndexHome),
                highlightIcon: Icons.local_shipping_rounded,
                highlightLabel: 'CP Delivery',
                highlightDescription: 'Create CPR record.',
                highlightOnTap: () => navigateToCPRDelivery(),
              )
            : _selectedIndex == kIndexPlanterReq
            ? _buildPlanterReqAppBar(context)
            : _selectedIndex == kIndexCPRForm
            ? _buildCPRFormAppBar(context)
            : _selectedIndex == kIndexCPRInfo
            ? _buildCPRInfoAppBar(context)
            : _selectedIndex == kIndexNotifications
            ? _buildNotificationsAppBar(context)
            : _selectedIndex == kIndexStatistics
            ? _buildGreenAppBar(
                context: context,
                title: 'Statistics',
                titleIcon: Icons.bar_chart_rounded,
                onBack: () => navigateTo(kIndexHome),
                showQuickCards: false,
              )
            : AppHeader(
                title: _titles[_selectedIndex],
                onNotificationTap: navigateToNotifications,
              ),
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: _isSubScreen
            ? null
            : BottomNav(
                selectedIndex: _selectedIndex,
                onTap: _onNavTap,
                outlineIcons: _outlineIcons,
                filledIcons: _filledIcons,
                labels: const ['Sync', 'Home', 'Profile'],
                isDark: isDark,
              ),
      ),
    );
  }

  // ─── Quick Card ──────────────────────────────────────────────────────────────
  Widget _buildQuickCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? description,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    final hasDesc = description != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: hasDesc ? 14 : 18,
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: highlight ? AppTheme.primary : Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: highlight
                ? Colors.transparent
                : Colors.black.withOpacity(0.10),
          ),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: hasDesc
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.70),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.50),
                    size: 14,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Dialogs / Snackbars ─────────────────────────────────────────────────────
  Future<void> _showClearDataDialog(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      icon: Icons.delete_sweep_rounded,
      iconColor: AppTheme.accentRed,
      title: 'Clear Local Data',
      message:
          'This will remove all locally stored data. This action cannot be undone.',
      confirmLabel: 'Clear',
      confirmColor: AppTheme.accentRed,
    );

    if (confirmed == true) {
      await DBHelper.clearAllData();
      if (mounted) _showSnackBar(context, 'Local data cleared', isError: false);
    }
  }

  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          side: BorderSide(color: context.appColors.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 13.5,
                  color: context.appColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(
                      foregroundColor: context.appColors.textSecondary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.dangerGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      boxShadow: [
                        BoxShadow(
                          color: confirmColor.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.accentRed : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}

// ─── Helper data class ────────────────────────────────────────────────────────
class _StatEntry {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _StatEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });
}
