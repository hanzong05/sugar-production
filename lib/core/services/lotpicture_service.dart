import 'package:sugar_production/core/db.dart';

class LotpictureService {
  static Future<int> insertLotPicture(Map<String, dynamic> lp) async {
    try {
      return await DBHelper.insertLotPicture(lp);
    } catch (e) {
      print('Error inserting Lot Picture: $e');
      rethrow;
    }
  }

  static Future<String?> getcprref(int id) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        cprtable,
        columns: [colccprrefno],
        where: '$colcprid = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return maps.first[colccprrefno]?.toString();
      }
      return null;
    } catch (e) {
      print('Error getting CPR refno by id: $e');
      rethrow;
    }
  }

  // ← NEW: get by request_id instead of primary key
  static Future<Map<String, dynamic>?> getLotPictureByRequestId(
    String requestId,
  ) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        lotPicturesTable,
        columns: [
          collpid,
          collpreqid,
          collandprep, // ← 'land_prep' path
          collandactual,
          'landprep_date',
          'actualplanted_date',
          'lp_traflag',
          'ap_traflag',
          'traflag',
        ],
        where: '$collpreqid = ?',
        whereArgs: [requestId],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print('Error getting Lot Picture by request_id: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getLotPictureImagesByRequestId(
    String requestId,
  ) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        lotPicturesTable,
        columns: [collpreqid, collandprep, collandactual],
        where: '$collpreqid = ?',
        whereArgs: [requestId],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print('Error getting Lot Picture by request_id: $e');
      rethrow;
    }
  }

  // ← NEW: update by request_id
  static Future<int> updateLotPictureByRequestId(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.update(
        lotPicturesTable,
        data,
        where: '$collpreqid = ?',
        whereArgs: [requestId],
      );
    } catch (e) {
      print('Error updating Lot Picture: $e');
      rethrow;
    }
  }

  static Future<int> upsertLotPicture(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final db = await DBHelper.db;
      final existing = await db.query(
        lotPicturesTable,
        columns: [collpid],
        where: '$collpreqid = ?',
        whereArgs: [requestId],
      );
      if (existing.isNotEmpty) {
        return await db.update(
          lotPicturesTable,
          data,
          where: '$collpreqid = ?',
          whereArgs: [requestId],
        );
      } else {
        return await db.insert(lotPicturesTable, data);
      }
    } catch (e) {
      print('Error upserting Lot Picture: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllLotPictures() async {
    try {
      final db = await DBHelper.db;
      return await db.query(lotPicturesTable);
    } catch (e) {
      print('Error getting all Lot Pictures: $e');
      rethrow;
    }
  }
}
