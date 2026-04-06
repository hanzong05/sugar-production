import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/core/db.dart';

class PlanterServices {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertPlanter(Map<String, dynamic> planter) async {
    try {
      return await DBHelper.insertPlanter(planter);
    } catch (e) {
      print('Error inserting planter: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getPlanters() async {
    try {
      final db = await DBHelper.db;
      return await db.query(planterTable);
    } catch (e) {
      print('Error getting planters: $e');
      rethrow;
    }
  }

  Future<List<Planter>> getAllPlanters() async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(planterTable, orderBy: '$colPlname ASC');
      return result.map((json) => Planter.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting all planters: $e');
      rethrow;
    }
  }

  Future<Planter?> getPlanterById(int plid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        planterTable,
        where: '$colPlid = ?',
        whereArgs: [plid],
      );
      return maps.isNotEmpty ? Planter.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting planter by id: $e');
      rethrow;
    }
  }

  Future<List<Planter>> searchPlanters(String query) async {
    try {
      if (query.isEmpty) return getAllPlanters();
      final db = await DBHelper.db;
      final result = await db.query(
        planterTable,
        where: '$colPlname LIKE ? OR $colPlcode LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: '$colPlname ASC',
      );
      return result.map((json) => Planter.fromMapObject(json)).toList();
    } catch (e) {
      print('Error searching planters: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPlanterDetailsByPLid(
    int planterid,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          c.*,
          p.$colPlcode as pl_code,
          p.$colPlname as pl_name
        FROM $cprtable c
        LEFT JOIN $planterTable p ON c.$colcprplanterid = p.$colPlid
        WHERE c.$colcprplanterid = ?
        ''',
        [planterid],
      );
    } catch (e) {
      print('Error getting planter details by id: $e');
      rethrow;
    }
  }
}
