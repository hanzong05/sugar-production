import 'package:flutter/material.dart';
import 'package:sugar_production/core/services/notification.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class NotificationItem {
  final int? id;
  final String title;
  final String body;
  final DateTime dateTime;

  const NotificationItem({
    this.id,
    required this.title,
    required this.body,
    required this.dateTime,
  });
}

void showNotificationModal(
  BuildContext context,
  List<NotificationItem> notifications, {
  int initialIndex = 0,
}) {
  assert(notifications.isNotEmpty, 'Notification list must not be empty');
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => NotificationModal(
      notifications: notifications,
      initialIndex: initialIndex,
    ),
  );
}

class NotificationModal extends StatefulWidget {
  final List<NotificationItem> notifications;
  final int initialIndex;

  const NotificationModal({
    super.key,
    required this.notifications,
    this.initialIndex = 0,
  });

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  late final PageController _pageController;
  late int _currentIndex;
  final Set<int> _seenIndexes = {};
  late List<NotificationItem> _notifications;

  bool get _hasMultiple => _notifications.length > 1;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _markCurrentAsSeen(widget.initialIndex);
    NotificationUtils.modalNotifier.addListener(_onNewNotifications);
  }

  void _onNewNotifications() {
    final incoming = NotificationUtils.modalNotifier.value;
    if (incoming.isEmpty) return;
    setState(() {
      for (final n in incoming) {
        final alreadyIn = _notifications.any((c) => c.id == n.id);
        if (!alreadyIn) _notifications.add(n);
      }
    });
  }

  void _markCurrentAsSeen(int index) {
    if (_seenIndexes.contains(index)) return;
    _seenIndexes.add(index);
    final item = _notifications[index];
    if (item.id != null) NotificationUtils.markAsRead(item.id!);
  }

  @override
  void dispose() {
    NotificationUtils.modalNotifier.removeListener(_onNewNotifications);
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
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
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, minHeight: 200),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: colors.border),
          boxShadow: AppTheme.shadowLG(dark: context.isDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),

            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _notifications.length,
                onPageChanged: (i) {
                  setState(() => _currentIndex = i);
                  _markCurrentAsSeen(i);
                },
                itemBuilder: (_, i) => _buildCard(context, _notifications[i]),
              ),
            ),

            if (_hasMultiple) _buildFooter(context),

            const SizedBox(height: 8),

            // Dismiss button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    boxShadow: AppTheme.shadowBrand(dark: context.isDark),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: const Icon(
              Icons.notifications_rounded,
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
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                if (_hasMultiple)
                  Text(
                    '${_currentIndex + 1} of ${_notifications.length}',
                    style: TextStyle(color: colors.textHint, fontSize: 12),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(color: colors.border),
              ),
              child: Icon(
                Icons.close_rounded,
                color: colors.textSecondary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card ──────────────────────────────────────────────────────────────────

  Widget _buildCard(BuildContext context, NotificationItem item) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.3,
              letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                item.body,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 13,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                _formatDateTime(item.dateTime),
                style: TextStyle(
                  color: colors.textHint,
                  fontSize: 11.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer (pagination) ───────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    final colors = context.appColors;
    final total = _notifications.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            enabled: _currentIndex > 0,
            onTap: () => _goTo(_currentIndex - 1),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final active = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary : colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          _NavButton(
            icon: Icons.arrow_forward_ios_rounded,
            enabled: _currentIndex < _notifications.length - 1,
            onTap: () => _goTo(_currentIndex + 1),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Nav Button
// ══════════════════════════════════════════════════════════════════

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primary.withOpacity(0.10)
              : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: enabled ? AppTheme.primary.withOpacity(0.40) : colors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.primary : colors.textHint,
        ),
      ),
    );
  }
}
