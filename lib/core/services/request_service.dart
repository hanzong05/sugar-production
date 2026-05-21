import 'package:sugar_production/models/modrequests.dart';
import 'package:sugar_production/core/db.dart';

class RequestService {
  // ─── Insert ─────────────────────────────────────────────────────────────────

  static Future<int> insertReq(Map<String, dynamic> req) async {
    try {
      return await DBHelper.insertReq(req);
    } catch (e) {
      print('Error inserting request: $e');
      rethrow;
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────────────

  Future<List<Requests>> getAllRequests() async {
    try {
      final db = await DBHelper.db;
      final result = await db.query(requestTable, orderBy: '$colReqdtr DESC');
      return result.map((json) => Requests.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting all requests: $e');
      rethrow;
    }
  }

  Future<Requests?> getRequestById(int reqid) async {
    try {
      final db = await DBHelper.db;
      final maps = await db.query(
        requestTable,
        where: '$colReqid = ?',
        whereArgs: [reqid],
      );
      return maps.isNotEmpty ? Requests.fromMapObject(maps.first) : null;
    } catch (e) {
      print('Error getting request by id: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getReqByPlanterCode(
    String planterCode,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.query(
        requestTable,
        where: '$colReqplcode = ?',
        whereArgs: [planterCode],
        orderBy: '$colReqdtr DESC',
      );
    } catch (e) {
      print('Error getting requests by planter code: $e');
      rethrow;
    }
  }

  Future<List<Requests>> getRequestsByPlanterCode(String planterCode) async {
    try {
      final result = await getReqByPlanterCode(planterCode);
      return result.map((json) => Requests.fromMapObject(json)).toList();
    } catch (e) {
      print('Error getting requests by planter code: $e');
      rethrow;
    }
  }

  Future<int> getRequestCountByPlanter(String planterCode) async {
    try {
      final result = await getReqByPlanterCode(planterCode);
      return result.length;
    } catch (e) {
      print('Error getting request count: $e');
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getReqByPlanterWithDetails(
    String planterCode,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          r.*,
          p.$colPlcode as pl_code,
          p.$colPlname as pl_name
        FROM $requestTable r
        LEFT JOIN $planterTable p ON r.$colReqplcode = p.$colPlcode
           WHERE r.$colReqplcode = ? AND r.$colforcpr != '1'
        ORDER BY r.$colReqdtr DESC
        ''',
        [planterCode],
      );
    } catch (e) {
      print('Error getting requests by planter with details: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getReqByPlanterWithDetailsForCpr(
    String planterCode,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          r.*,
          p.$colPlcode as pl_code,
          p.$colPlname as pl_name
        FROM $requestTable r
        LEFT JOIN $planterTable p ON r.$colReqplcode = p.$colPlcode
        WHERE r.$colReqplcode = ? AND r.$colforcpr != '0'
        ORDER BY r.$colReqdtr DESC
        ''',
        [planterCode],
      );
    } catch (e) {
      print('Error getting requests by planter with details: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllReqWithDetails() async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery('''
        SELECT
          r.*,
          p.$colPlcode as pl_code,
          p.$colPlname as pl_name
        FROM $requestTable r
        LEFT JOIN $planterTable p ON r.$colReqplcode = p.$colPlcode
        ORDER BY r.$colReqdtr DESC
      ''');
    } catch (e) {
      print('Error getting all requests with details: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getRequestDetailsByid(
    int requestid,
  ) async {
    try {
      final db = await DBHelper.db;
      return await db.rawQuery(
        '''
        SELECT
          c.*,
          r.$colReqno as request_no,
          r.$colReqlotlocation as lot_location
        FROM $cprtable c
        LEFT JOIN $requestTable r ON c.$colcprrequestid = r.$colReqid
        WHERE c.$colcprrequestid = ?
        ''',
        [requestid],
      );
    } catch (e) {
      print('Error getting request details by id: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRequestsByPlanterWithDetails(
    String planterCode,
  ) async {
    try {
      final result = await getReqByPlanterWithDetails(planterCode);
      return result.map((row) => _appendStatus(row)).toList();
    } catch (e) {
      print('Error getting requests by planter with details: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRequestsByPlanterWithDetailsForCpr(
    String planterCode,
  ) async {
    try {
      final result = await getReqByPlanterWithDetailsForCpr(planterCode);
      return result.map((row) => _appendStatus(row)).toList();
    } catch (e) {
      print('Error getting requests by planter with details: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllRequestsWithDetails() async {
    try {
      final result = await getAllReqWithDetails();
      return result.map((row) => _appendStatus(row)).toList();
    } catch (e) {
      print('Error getting all requests with details: $e');
      rethrow;
    }
  }

  // ─── Update ──────────────────────────────────────────────────────────────────

  static Future<int> addDeliveredQty({
    required int reqId,
    required int additionalQty,
  }) async {
    try {
      final db = await DBHelper.db;

      final result = await db.query(
        requestTable,
        columns: [colReqdlqty, colReqrmqty],
        where: '$colReqid = ?',
        whereArgs: [reqId],
      );

      if (result.isEmpty) throw Exception('Request not found: $reqId');

      final currentQty = result.first[colReqdlqty] as int? ?? 0;
      final remainingqty = result.first[colReqrmqty] as int? ?? 0;
      final newTotalQty = currentQty + additionalQty;
      final newremaining = remainingqty - additionalQty;

      return await db.update(
        requestTable,
        {colReqdlqty: newTotalQty, colReqrmqty: newremaining},
        where: '$colReqid = ?',
        whereArgs: [reqId],
      );
    } catch (e) {
      print('Error updating delivered qty: $e');
      rethrow;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> _appendStatus(Map<String, dynamic> row) {
    final totalQty = row[colReqttlqty] as int? ?? 0;
    final deliveredQty = row[colReqdlqty] as int? ?? 0;
    final remainingQty = row[colReqrmqty] as int? ?? 0;

    int status;
    if (deliveredQty == 0) {
      status = 0; // Not Served
    } else if (deliveredQty < totalQty) {
      status = 1; // Partially Served
    } else {
      status = 9; // Fully Served
    }

    return {
      ...row,
      'total_qty': totalQty,
      'delivered_qty': deliveredQty,
      'remaining_qty': remainingQty,
      'status': status,
    };
  }

  Future<List<Requests>> searchRequest(String query) async {
    try {
      if (query.isEmpty) return getAllRequests();
      final db = await DBHelper.db;
      final result = await db.query(
        requestTable,
        where: '$colReqlotlocation LIKE ? OR $colReqno LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: '$colReqdtr ASC',
      );
      return result.map((json) => Requests.fromMapObject(json)).toList();
    } catch (e) {
      print('Error searching planters: $e');
      rethrow;
    }
  }
}
