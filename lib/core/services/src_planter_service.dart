import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modsrcplanter.dart';

class SourcePlanterService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertSourcePlanter(Map<String, dynamic> planter) async {
    try {
      return await DBHelper.insertSourcePlanter(planter);
    } catch (e) {
      print('Error inserting source planter: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllSourcePl() async {
    try {
      final db = await DBHelper.db;
      return await db.query(srcplanterTable, orderBy: '$colPlsrcid ASC');
    } catch (e) {
      print('Error getting all source planters: $e');
      rethrow;
    }
  }

  Future<SourcePlanter?> getSourcePlbyId(int srcId) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        srcplanterTable,
        where: '$colPlsrcid = ?',
        whereArgs: [srcId],
      );
      return maps.isNotEmpty ? SourcePlanter.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting source planter by id: $e');
      rethrow;
    }
  }
}
