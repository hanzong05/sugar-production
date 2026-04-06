import 'package:flutter/material.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/core/services/data.dart';

class StatisticsController extends ChangeNotifier {
  bool isLoading = true;

  int totalRequests = 0;
  int totalCPR = 0;
  int unsyncedCPR = 0;
  int syncedCPR = 0;
  int totalPlanters = 0;
  Map<String, dynamic>? latestCPR;

  StatisticsController() {
    loadStats();
    DataNotifier.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() => loadStats();

  Future<void> loadStats() async {
    isLoading = true;
    notifyListeners();

    try {
      final db = await DBHelper.db;

      final reqResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $requestTable',
      );
      final planterResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $planterTable',
      );
      final latestResult = await db.rawQuery('''
        SELECT c.$colccprrefno, c.$colcprdatedelivered, c.$colcprqty,
               c.$colcprtraflag, p.$colPlname
        FROM $cprtable c
        LEFT JOIN $planterTable p ON c.$colcprplanterid = p.$colPlid
        ORDER BY c.$colcprid DESC
        LIMIT 1
      ''');

      final syncStats = await CprService.getSyncStats();

      totalRequests = (reqResult.first['count'] as int?) ?? 0;
      totalPlanters = (planterResult.first['count'] as int?) ?? 0;
      totalCPR = syncStats['total'] ?? 0;
      unsyncedCPR = syncStats['unsynced'] ?? 0;
      syncedCPR = syncStats['synced'] ?? 0;
      latestCPR = latestResult.isNotEmpty ? latestResult.first : null;
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(String? s) {
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
      return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return s;
    }
  }

  @override
  void dispose() {
    DataNotifier.instance.removeListener(_onDataChanged);
    super.dispose();
  }
}
