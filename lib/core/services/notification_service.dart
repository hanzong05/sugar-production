import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modnotif.dart';
import 'package:flutter/material.dart';
import 'package:sugar_production/features/homepage/widgets/notification_modal.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Global navigator key — attach this to MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  void showNotification(List<NotificationItem> notifications) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showNotificationModal(context, notifications);
  }
  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final db = await DBHelper.db;
      return await db.query(notiftable, orderBy: '$colnotifdatetime DESC');
    } catch (e) {
      print('Error getting all notification: $e');
      rethrow;
    }
  }

  Future<Notifications?> getnotifbyId(int notifid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        notiftable,
        where: '$colnotifid = ?',
        whereArgs: [notifid],
      );
      return maps.isNotEmpty ? Notifications.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting cutter by id: $e');
      rethrow;
    }
  }

  Future<Notifications?> updatetraflag(int notifid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        notiftable,
        where: '$colnotifid = ?',
        whereArgs: [notifid],
      );
      return maps.isNotEmpty ? Notifications.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting cutter by id: $e');
      rethrow;
    }
  }
}
