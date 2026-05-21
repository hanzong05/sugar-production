import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/services/request_service.dart';

class CprService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> submitDelivery({
    required Map<String, dynamic> cprData,
    required int requestId,
    required int qty,
  }) async {
    try {
      final cprId = await DBHelper.insertCPR(cprData);
      await RequestService.addDeliveredQty(
        reqId: requestId,
        additionalQty: qty,
      );
      return cprId;
    } catch (e) {
      print('Error submitting delivery: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getCpr() async {
    try {
      final db = await DBHelper.db;
      return await db.query(cprtable);
    } catch (e) {
      print('Error getting planters: $e');
      rethrow;
    }
  }

  static Future<int> insertCPR(Map<String, dynamic> cpr) async {
    try {
      return await DBHelper.insertCPR(cpr);
    } catch (e) {
      print('Error inserting CPR: $e');
      rethrow;
    }
  }

  // ─── Sync Status ────────────────────────────────────────────────────────────

  static Future<int> getUnsyncedCount() async {
    try {
      final db = await DBHelper.db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $cprtable WHERE $colcprtraflag != ?',
        ['S'],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting unsynced count: $e');
      return 0;
    }
  }

  static Future<int> getSyncedCount() async {
    try {
      final db = await DBHelper.db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $cprtable WHERE $colcprtraflag = ?',
        ['S'],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting synced count: $e');
      return 0;
    }
  }

  static Future<int> getTotalCount() async {
    try {
      final db = await DBHelper.db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $cprtable',
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  static Future<Map<String, int>> getSyncStats() async {
    try {
      final unsynced = await getUnsyncedCount();
      final synced = await getSyncedCount();
      final total = await getTotalCount();
      return {'unsynced': unsynced, 'synced': synced, 'total': total};
    } catch (e) {
      print('Error getting sync stats: $e');
      return {'unsynced': 0, 'synced': 0, 'total': 0};
    }
  }

  static Future<List<CPR>> getUnsyncedCPR() async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(
        cprtable,
        where: '$colcprtraflag != ?',
        whereArgs: ['S'],
        orderBy: '$colcprdatedelivered DESC',
      );
      return result.map((json) => CPR.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting unsynced CPR: $e');
      return [];
    }
  }

  static Future<List<CPR>> getSyncedCPR() async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(
        cprtable,
        where: '$colcprtraflag = ?',
        whereArgs: ['S'],
        orderBy: '$colcprdatedelivered DESC',
      );
      return result.map((json) => CPR.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting synced CPR: $e');
      return [];
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllCPR() async {
    try {
      final db = await DBHelper.db;
      return await db.query(cprtable, orderBy: '$colcprdatedelivered ASC');
    } catch (e) {
      print('Error getting all CPR: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllcprs() async {
    try {
      final db = await DBHelper.db;
      return await db.query(cprtable, orderBy: '$colcprdatedelivered DESC');
    } catch (e) {
      print('Error getting all cprs: $e');
      rethrow;
    }
  }

  static Future<List<CPR>> getAllcpr() async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(
        cprtable,
        orderBy: '$colcprdatedelivered DESC',
      );
      return result.map((json) => CPR.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting all cprs: $e');
      rethrow;
    }
  }

  static Future<List<CPR>> searchcprs(String query) async {
    try {
      if (query.isEmpty) return getAllcpr();
      final db = await DBHelper.db;
      final result = await db.rawQuery(
        '''
          SELECT c.*
          FROM $cprtable c
          LEFT JOIN $planterTable p ON c.$colcprplanterid = p.$colPlid
          WHERE c.$colccprrefno LIKE ?
            OR p.$colPlname LIKE ?
          ORDER BY c.$colcprdatedelivered DESC
        ''',
        ['%$query%', '%$query%'],
      );
      return result.map((json) => CPR.fromMapObject(json)).toList();
    } catch (e) {
      print('Error searching cprs: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCprByCode(String code) async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(
        cprtable,
        where: '$colccprrefno = ?',
        whereArgs: [code],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting CPR by code: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getcprsByPlanterId(
    int planterId,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.query(
        cprtable,
        where: '$colcprplanterid = ?',
        whereArgs: [planterId],
        orderBy: '$colcprdatedelivered DESC',
      );
    } catch (e) {
      print('Error getting cprs by planter id: $e');
      rethrow;
    }
  }

  static Future<Map<String, String>> getcprDetails(CPR cpr) async {
    try {
      final db = await DBHelper.db;

      // Planter name
      final planterResult = await db.query(
        planterTable,
        columns: [colPlname],
        where: '$colPlid = ?',
        whereArgs: [cpr.colcprplanterid],
      );
      final planterName = planterResult.isNotEmpty
          ? planterResult.first[colPlname] as String
          : 'N/A';

      // Request number + lot location
      final requestResult = await db.query(
        requestTable,
        columns: [colReqno, colReqlotlocation],
        where: '$colReqid = ?',
        whereArgs: [cpr.colcprrequestid],
      );
      final requestNumber = requestResult.isNotEmpty
          ? requestResult.first[colReqno].toString()
          : 'N/A';
      final lotLocation = requestResult.isNotEmpty
          ? requestResult.first[colReqlotlocation] as String
          : 'N/A';

      // Variety
      final varietyResult = await db.query(
        varietytable,
        columns: [colvardesc],
        where: '$colvarid = ?',
        whereArgs: [cpr.colcprvarietyid],
      );
      final variety = varietyResult.isNotEmpty
          ? varietyResult.first[colvardesc] as String
          : 'N/A';

      // Cutter
      final cutterResult = await db.query(
        cuttertable,
        columns: [colctrdesc],
        where: '$colctrid = ?',
        whereArgs: [cpr.colcprcutterid],
      );
      final cutter = cutterResult.isNotEmpty
          ? cutterResult.first[colctrdesc] as String
          : 'N/A';

      final cmResult = await db.query(
        cuttingmodetable,
        columns: [colcmdesc],
        where: '$colcmid = ?',
        whereArgs: [cpr.colcprcm],
      );
      final cm = cmResult.isNotEmpty
          ? cmResult.first[colcmdesc] as String
          : 'N/A';
      // Source location
      final locationResult = await db.query(
        locationtable,
        columns: [colloclocation],
        where: '$collocid = ?',
        whereArgs: [cpr.colcprlocid],
      );
      final sourceLocation = locationResult.isNotEmpty
          ? locationResult.first[colloclocation] as String
          : 'N/A';

      // Delivered by
      final userResult = await db.query(
        userTable,
        columns: [fullname],
        where: '$usernameid = ?',
        whereArgs: [cpr.colcprdeliveredby],
      );
      final deliveredByName = userResult.isNotEmpty
          ? userResult.first[fullname] as String
          : 'N/A';

      // Source location
      final coordinatorResult = await db.query(
        frTable,
        columns: [colfrname],
        where: '$colfrid = ?',
        whereArgs: [cpr.colcprcoordid],
      );
      final coordinator = coordinatorResult.isNotEmpty
          ? coordinatorResult.first[colfrname] as String
          : 'N/A';

      // Source location
      final srcplanterResult = await db.query(
        srcplanterTable,
        columns: [colPlsrcname, colPlsrccode],
        where: '$colPlsrcid = ?',
        whereArgs: [cpr.colcprsourceplanter],
      );
      final plsourceName = srcplanterResult.isNotEmpty
          ? srcplanterResult.first[colPlsrcname] as String
          : 'N/A';
      final plsourcecode = srcplanterResult.isNotEmpty
          ? srcplanterResult.first[colPlsrccode] as String
          : 'N/A';

      return {
        'planterName': planterName,
        'requestNumber': requestNumber,
        'lotLocation': lotLocation,
        'variety': variety,
        'cutter': cutter,
        'sourceLocation': sourceLocation,
        'deliveredByName': deliveredByName,
        'coordinator': coordinator,
        'cuttingmode': cm,
        'sourceplanter': plsourceName,
        'sourceplanter_code': plsourcecode,
      };
    } catch (e) {
      print('Error getting cpr details: $e');
      rethrow;
    }
  }

  static Future<CPR?> getcprsById(int cprId) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        cprtable,
        where: '$colcprid = ?',
        whereArgs: [cprId],
      );
      return maps.isNotEmpty ? CPR.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting CPR by id: $e');
      rethrow;
    }
  }

  static Future<String?> getreqid(int id) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        lotPicturesTable,
        columns: [collpreqid],
        where: '$collpid = ?',
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

  static Future<int> incrementPrintCount(int cprId) async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(
        cprtable,
        columns: [colcprcounter],
        where: '$colcprid = ?',
        whereArgs: [cprId],
      );
      if (result.isEmpty) throw Exception('CPR not found: $cprId');
      final current = result.first[colcprcounter] as int? ?? 0;
      return await db.update(
        cprtable,
        {colcprcounter: current + 1},
        where: '$colcprid = ?',
        whereArgs: [cprId],
      );
    } catch (e) {
      print('Error incrementing print count: $e');
      rethrow;
    }
  }

  static Future<int> incrementSeries(int cprId) async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(
        cprtable,
        columns: [colcprseries],
        where: '$colcprid = ?',
        whereArgs: [cprId],
      );
      if (result.isEmpty) throw Exception('CPR not found: $cprId');
      final current = result.first[colcprseries] as int? ?? 0;
      print('BILANG $current');
      return await db.update(
        cprtable,
        {colcprseries: current},
        where: '$colcprid = ?',
        whereArgs: [cprId],
      );
    } catch (e) {
      print('Error incrementing series: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> generatecprCode(String userId) async {
    final db = await DBHelper.db;

    final result = await db.rawQuery(
      'SELECT COALESCE(MAX($colcprseries), 0) as maxSeries FROM $cprtable',
    );

    final maxSeries = (result.first['maxSeries'] as int?) ?? 0;

    final nextSeries = maxSeries + 1; // ✅ increment FIRST

    return {
      'refno': '$userId-${nextSeries.toString().padLeft(4, '0')}',
      'series': nextSeries,
    };
  }
}
