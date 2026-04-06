import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modcoord.dart';

class CoordsService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertCoords(Map<String, dynamic> fr) async {
    try {
      return await DBHelper.insertCoords(fr);
    } catch (e) {
      print('Error inserting coordinator: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllCoords() async {
    try {
      final db = await DBHelper.db;
      return await db.query(frTable, orderBy: '$colfrid ASC');
    } catch (e) {
      print('Error getting all coordinators: $e');
      rethrow;
    }
  }

  Future<Coordinators?> getCoordsbyId(int coordid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        frTable,
        where: '$colfrid = ?',
        whereArgs: [coordid],
      );
      return maps.isNotEmpty ? Coordinators.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting coordinator by id: $e');
      rethrow;
    }
  }
}
