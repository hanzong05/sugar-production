import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modcutter.dart';

class CutterService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertCutter(Map<String, dynamic> cut) async {
    try {
      return await DBHelper.insertCutter(cut);
    } catch (e) {
      print('Error inserting cutter: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllCutters() async {
    try {
      final db = await DBHelper.db;
      return await db.query(cuttertable, orderBy: '$colctrid ASC');
    } catch (e) {
      print('Error getting all cutters: $e');
      rethrow;
    }
  }

  Future<Cutters?> getCutterById(int cutid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        cuttertable,
        where: '$colctrid = ?',
        whereArgs: [cutid],
      );
      return maps.isNotEmpty ? Cutters.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting cutter by id: $e');
      rethrow;
    }
  }

  Future<int> updatetraflag(int notifid) async {
    try {
      final db = await DBHelper.db;
      return await db.update(
        notiftable,
        {colnotiftraflag: 1},
        where: '$colnotifid = ?',
        whereArgs: [notifid],
      );
    } catch (e) {
      print('Error updating traflag: $e');
      rethrow;
    }
  }
}
