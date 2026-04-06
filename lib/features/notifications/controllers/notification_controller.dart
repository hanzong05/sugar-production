import 'package:flutter/material.dart';
import 'package:sugar_production/models/modnotif.dart';
import 'package:sugar_production/core/services/notification.dart';

class NotificationsController extends ChangeNotifier {
  List<Notifications> notifications = [];
  bool isLoading = false;
  String? error;

  NotificationsController() {
    loadData();
    NotificationUtils.modalNotifier.addListener(_onNewNotification);
  }

  void _onNewNotification() {
    final incoming = NotificationUtils.modalNotifier.value;
    if (incoming.isEmpty) return;
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final maps = await NotificationUtils.getAllNotifications();
      notifications = maps.map((m) => Notifications.fromMapObject(m)).toList();
    } catch (e) {
      error = 'Error loading data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(int index) {
    final n = notifications[index];
    if (n.traflag == 0) {
      notifications[index] = notifications[index].copyWith(traflag: 1);
      if (n.notifid != null) NotificationUtils.markAsRead(n.notifid!);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    NotificationUtils.modalNotifier.removeListener(_onNewNotification);
    super.dispose();
  }
}
