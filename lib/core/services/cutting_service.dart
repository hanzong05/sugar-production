import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modcutting.dart';

class CuttingService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertCm(Map<String, dynamic> cut) async {
    try {
      return await DBHelper.insertCM(cut);
    } catch (e) {
      print('Error inserting cutter: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllCm() async {
    try {
      final db = await DBHelper.db;
      return await db.query(cuttingmodetable, orderBy: '$colcmid ASC');
    } catch (e) {
      print('Error getting all cutters: $e');
      rethrow;
    }
  }

  Future<Cutting?> getCmByID(int cutid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        cuttingmodetable,
        where: '$colcmid = ?',
        whereArgs: [cutid],
      );
      return maps.isNotEmpty ? Cutting.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting cutter by id: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getCmdetailsbyid(int ctngid) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          c.*,
          ct.$colcprcm as description
        FROM $cprtable c
        LEFT JOIN $cuttingmodetable ct ON c.$colcprcm = ct.$colcmid
        WHERE c.$colcprcutter = ?
        ''',
        [ctngid],
      );
    } catch (e) {
      print('Error getting cutter details by id: $e');
      rethrow;
    }
  }
}
