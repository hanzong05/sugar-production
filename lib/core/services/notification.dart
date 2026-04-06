import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_production/app.dart' show navigatorKey;
import 'package:sugar_production/features/homepage/widgets/notification_modal.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modnotif.dart';

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _prefKey = 'pending_notifications';

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        NotificationUtils._showModalFromStorage();
      },
    );
  }

  static Future<void> handleAppLaunch() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showModalFromStorage();
      });
    }
  }

  static Future<void> _showModalFromStorage() async {
    await checkPendingOnResume();
  }

  static Future<void> saveToPrefs(
    String title,
    String body,
    String timestamp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefKey) ?? [];
    existing.add(
      jsonEncode({
        'title': title,
        'body': body,
        'dateTime':
            DateTime.tryParse(timestamp)?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      }),
    );
    await prefs.setStringList(_prefKey, existing);
    print('[NOTIF] Saved to prefs: $title | Total: ${existing.length}');
  }

  static Future<List<NotificationItem>> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getStringList(_prefKey) ?? [];
    if (raw.isEmpty) return [];
    await prefs.remove(_prefKey);
    return raw.map((e) {
      final map = jsonDecode(e);
      return NotificationItem(
        title: map['title'],
        body: map['body'],
        dateTime: DateTime.parse(map['dateTime']),
      );
    }).toList();
  }

  static bool _isShowingModal = false;

  /// Notifier for the modal (used inside NotificationModal widget)
  static final ValueNotifier<List<NotificationItem>> modalNotifier =
      ValueNotifier([]);

  /// Notifier for NotificationsScreen — fires whenever DB changes
  static final ValueNotifier<int> screenNotifier = ValueNotifier(0);

  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);

  static Future<void> refreshUnreadcount() async {
    final unread = await _getUnreadFromDB();

    unreadCountNotifier.value = unread.length;
  }

  static Future<void> checkPendingOnResume() async {
    // print('[NOTIF] checkPendingOnResume called');

    final dbUnread = await _getUnreadFromDB();
    // print('[NOTIF] DB unread count: ${dbUnread.length}');

    if (dbUnread.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
      return;
    }

    int retries = 0;
    while (navigatorKey.currentContext == null && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }

    if (navigatorKey.currentContext == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);

    if (_isShowingModal) {
      print('[NOTIF] Modal open — appending new notifications');

      final current = modalNotifier.value;
      final newOnly = dbUnread
          .where((n) => !current.any((c) => c.id == n.id))
          .toList();

      if (newOnly.isNotEmpty) {
        for (var n in newOnly) {
          await DBHelper.insertNotif({
            'id': n.id,
            'title': n.title,
            'body': n.body,
            'date_time': n.dateTime.toIso8601String(),
            'traflag': 0,
          });
        }
        modalNotifier.value = [...modalNotifier.value, ...newOnly];
        print('[NOTIF] Appended ${newOnly.length} new slides');
      }
      return;
    }

    _isShowingModal = true;
    modalNotifier.value = dbUnread;
    unreadCountNotifier.value = dbUnread.length;
    screenNotifier.value++; // 🔔 notify screen of new data
    print('[NOTIF] Showing modal with ${dbUnread.length} notifications');
    await showDialog(
      context: navigatorKey.currentContext!,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => NotificationModal(notifications: dbUnread),
    );
    _isShowingModal = false;
    modalNotifier.value = [];
    print('[NOTIF] Modal dismissed');
  }

  static Future<List<NotificationItem>> _getUnreadFromDB() async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        notiftable,
        where: '$colnotiftraflag = ?',
        whereArgs: [0],
        orderBy: '$colnotifdatetime DESC',
      );
      return maps.map((e) {
        final n = Notifications.fromMapObject(e);
        return NotificationItem(
          id: n.notifid,
          title: n.notiftitle ?? '',
          body: n.notifbody ?? '',
          dateTime: DateTime.tryParse(n.notifdatetime ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('[NOTIF] DB unread error: $e');
      return [];
    }
  }

  static Future<void> markAsRead(int id) async {
    try {
      final db = await DBHelper.db;
      await db.update(
        notiftable,
        {colnotiftraflag: 1},
        where: '$colnotifid = ?',
        whereArgs: [id],
      );
      await refreshUnreadcount();
      print('[NOTIF] Marked as read: $id');
    } catch (e) {
      print('[NOTIF] Error marking as read: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await DBHelper.db;
    return await db.query(notiftable, orderBy: '$colnotifdatetime DESC');
  }
}
