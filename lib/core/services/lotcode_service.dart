import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modlotcode.dart';

class LotcodeService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> LotCode(Map<String, dynamic> lot) async {
    try {
      return await DBHelper.insertLotCode(lot);
    } catch (e) {
      print('Error inserting LotCode: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllLotCodes() async {
    try {
      final db = await DBHelper.db;
      return await db.query(cuttertable, orderBy: '$colctrid ASC');
    } catch (e) {
      print('Error getting all LotCode: $e');
      rethrow;
    }
  }

  Future<Lots?> getLotCodeById(int cutid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        cuttertable,
        where: '$colctrid = ?',
        whereArgs: [cutid],
      );
      return maps.isNotEmpty ? Lots.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting Lot Code by id: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getLotCodesBySourcePlanter(
    int psid,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.query(
        lotcodeTable,
        where: '$colplsrcId = ?',
        whereArgs: [psid],
      );
    } catch (e) {
      print('Error getting LotCodes by source planter: $e');
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
