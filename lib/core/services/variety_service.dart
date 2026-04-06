import 'package:sugar_production/models/modvariety.dart';
import 'package:sugar_production/core/db.dart';

class VarietyService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertVariety(Map<String, dynamic> vrt) async {
    try {
      return await DBHelper.insertVariety(vrt);
    } catch (e) {
      print('Error inserting variety: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  Future<List<Variety>> getAllvar() async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(varietytable, orderBy: '$colvarid ASC');
      return result.map((json) => Variety.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting all varieties: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllVariety() async {
    try {
      final db = await DBHelper.db;
      return await db.query(varietytable, orderBy: '$colvarid ASC');
    } catch (e) {
      print('Error getting all varieties: $e');
      rethrow;
    }
  }

  Future<Variety?> getVarietyById(int varid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        varietytable,
        where: '$colvarid = ?',
        whereArgs: [varid],
      );
      return maps.isNotEmpty ? Variety.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting variety by id: $e');
      rethrow;
    }
  }

  Future<List<Variety>> searchVarieties(String query) async {
    try {
      if (query.isEmpty) return getAllvar();
      final db = await DBHelper.db;
      final result = await db.query(
        varietytable,
        where: '$colvardesc LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: '$colvarid ASC',
      );
      return result.map((json) => Variety.fromMapObject(json)).toList();
    } catch (e) {
      print('Error searching varieties: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getVarietyDetailsByid(
    int varid,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          c.*,
          v.$colvardesc as description
        FROM $cprtable c
        LEFT JOIN $varietytable v ON c.$colcprvariety = v.$colvarid
        WHERE c.$colcprvariety = ?
        ''',
        [varid],
      );
    } catch (e) {
      print('Error getting variety details by id: $e');
      rethrow;
    }
  }
}
