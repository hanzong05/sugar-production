import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/features/homepage/widgets/notification_modal.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = NotificationsController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openNotification(int index) async {
    _ctrl.markAsRead(index);

    final n = _ctrl.notifications[index];
    DateTime dt;
    try {
      dt = DateTime.parse(n.notifdatetime);
    } catch (_) {
      dt = DateTime.now();
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => NotificationModal(
        notifications: [
          NotificationItem(
            id: n.notifid,
            title: n.notiftitle,
            body: n.notifbody,
            dateTime: dt,
          ),
        ],
        initialIndex: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Show error snackbar if needed
    if (_ctrl.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _ctrl.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_ctrl.error!)),
                ],
              ),
              backgroundColor: AppTheme.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CPR INFO'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
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
                    child: _ctrl.notifications.isEmpty
                        ? const NotificationsEmptyState()
                        : RefreshIndicator(
                            onRefresh: _ctrl.loadData,
                            color: AppTheme.primary,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                MediaQuery.of(context).padding.bottom + 24,
                              ),
                              itemCount: _ctrl.notifications.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: NotificationListItem(
                                  notification: _ctrl.notifications[index],
                                  onTap: () => _openNotification(index),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
