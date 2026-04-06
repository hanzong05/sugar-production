import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modlocation.dart';

class LocationService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertLocation(Map<String, dynamic> location) async {
    try {
      return await DBHelper.insertLocation(location);
    } catch (e) {
      print('Error inserting location: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      final db = await DBHelper.db;
      return await db.query(locationtable, orderBy: '$collocid ASC');
    } catch (e) {
      print('Error getting all locations: $e');
      rethrow;
    }
  }

  Future<Location?> getLocationById(int locid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        locationtable,
        where: '$collocid = ?',
        whereArgs: [locid],
      );
      return maps.isNotEmpty ? Location.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting location by id: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getLocationDetailsByid(
    int locid,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          c.*,
          l.$colloclocation as description
        FROM $cprtable c
        LEFT JOIN $locationtable l ON c.$colcprlocid = l.$collocid
        WHERE c.$colcprlocid = ?
        ''',
        [locid],
      );
    } catch (e) {
      print('Error getting location details by id: $e');
      rethrow;
    }
  }
}
