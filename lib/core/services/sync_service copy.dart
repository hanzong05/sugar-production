// lib/services/sync_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;
import 'package:sugar_production/models/modcoord.dart';
import 'package:sugar_production/core/constants/api_constants.dart';
import 'package:sugar_production/core/services/planter_service.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modsynctoserver.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/models/modsrcplanter.dart';
import 'package:sugar_production/models/modcutter.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/models/modlocation.dart';
import 'package:sugar_production/models/modrequests.dart';
import 'package:sugar_production/models/modvariety.dart';
import 'package:sugar_production/models/modcutting.dart';
import 'package:sugar_production/models/modlotcode.dart';
import 'package:sugar_production/models/modlotpicture.dart';
import 'package:sugar_production/models/moduserpermissions.dart';
import 'package:sugar_production/core/constants/globals.dart' as globals;
import 'package:sugar_production/core/services/data.dart';

Future<void> download_cpr_Image(int imageName, String refno) async {
  final baseUrl =
      'https://cattarlac.synology.me:8182/web_images/sugar_production/cane_points/';

  final cprFiles = {
    'pic': {'server': '$imageName-pic.jpg', 'local': 'pic_$refno.jpg'},
    'sig': {'server': '$imageName-sig.jpg', 'local': 'sig_$refno.jpg'},
    'sppic': {'server': '$imageName-sppic.jpg', 'local': 'spd_$refno.jpg'},
  };

  for (var entry in cprFiles.entries) {
    final serverFile = entry.value['server']!;
    final localFile = entry.value['local']!;
    final url = '$baseUrl$serverFile';

    try {
      final response = await http.get(Uri.parse(url));

      final directory = Directory('/storage/emulated/0/DCIM/CPR_IMAGES');

      // ✅ Create folder if not exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final path = '${directory.path}/$localFile';
      final file = File(path);

      // Optional: delete old file
      if (await file.exists()) {
        await file.delete();
      }

      await file.writeAsBytes(response.bodyBytes, flush: true);
    } catch (e) {
      print('Error downloading $serverFile: $e');
    }
  }
}

Future<void> download_lp_Image(int imageName, String requestId) async {
  final baseUrl =
      'https://cattarlac.synology.me:8182/web_images/sugar_production/cane_points/';

  final lpFiles = {
    'ap': {'server': '$imageName-ap.jpg', 'local': 'ap_$requestId.jpg'},
    'lp': {'server': '$imageName-lp.jpg', 'local': 'lp_$requestId.jpg'},
  };

  for (var entry in lpFiles.entries) {
    final serverFile = entry.value['server']!;
    final localFile = entry.value['local']!;
    final url = '$baseUrl$serverFile';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = Directory('/storage/emulated/0/DCIM/LOT_PICTURES');

        // ✅ Create folder if not exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final path = '${directory.path}/$localFile';
        final file = File(path);

        if (await file.exists()) {
          await file.delete();
        }

        await file.writeAsBytes(response.bodyBytes, flush: true);
      }
    } catch (e) {
      print('Error downloading $serverFile: $e');
    }
  }
}

class SyncService {
  // Progress callback
  Function(double progress, String status)? onProgress;

  String _friendlyError(Object e) {
    if (e is SocketException) {
      return 'Cannot connect to server. Check your network connection.';
    }
    if (e is TimeoutException) {
      return 'Connection timed out. The server took too long to respond.';
    }
    if (e is HandshakeException) {
      return 'Secure connection failed. Check your server settings.';
    }
    if (e is HttpException) return 'Server returned an unexpected response.';
    if (e is FormatException) return 'Server returned invalid data.';
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot connect to server. Check your network connection.';
    }
    if (msg.contains('timed out') || msg.contains('TimeoutException')) {
      return 'Connection timed out. The server took too long to respond.';
    }
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Authentication failed. Please log in again.';
    }
    return 'Unexpected error. Please try again.';
  }

  void _updateProgress(double progress, String status) {
    if (onProgress != null) {
      onProgress!(progress, status);
    }
  }

  Future<void> _addImageFilePart(
    http.MultipartRequest request,
    dynamic filePath,
    String fieldName,
  ) async {
    final path = (filePath ?? '').toString();
    if (path.isEmpty) return;

    final file = File(path);
    if (!await file.exists()) return;

    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        path,
        filename: '$fieldName.jpg',
      ),
    );
  }

  Future<bool?> savesyncfirst(context, conntype) async {
    Planterjson planterjson = Planterjson(data: []);
    PlanterSourcejson plantersourcejson = PlanterSourcejson(data: []);
    LotCodejson lotcodejson = LotCodejson(data: []);
    Cutterjson cuttersjson = Cutterjson(data: []);
    SrcLocationjson locationsjson = SrcLocationjson(data: []);
    Varietyjson varietyjson = Varietyjson(data: []);
    Requestjson requestsjson = Requestjson(data: []);
    Coordinatorjson coordinatorjson = Coordinatorjson(data: []);
    Cprjson cprjson = Cprjson(data: []);
    CMjson cmjson = CMjson(data: []);
    PermissionsJson permissionsJson = PermissionsJson(data: []);
    int? usernameid = globals.globalusernameid;
    LotPictureJson lotpicturesjson = LotPictureJson(data: []);
    ApiConstants.conntype = conntype;
    final apiEndpoint =
        '${ApiConstants.baseUrl}/${ApiConstants.savesyncfirst}?usernameid=$usernameid';

    try {
      _updateProgress(0.05, 'Connecting to server...');

      Response response = await http
          .get(
            Uri.parse(apiEndpoint),
            headers: {
              HttpHeaders.authorizationHeader: globals.globalhttpauth
                  .toString(),
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final db = await DBHelper.db;
        final batch = db.batch();
        _updateProgress(0.10, 'Processing planters...');
        planterjson = plantersFromJson(response.body);
        for (var i = 0; i < planterjson.data.length; i++) {
          int? plid = int.parse(planterjson.data[i].plid);
          String? plcode = planterjson.data[i].plcode;
          String? plname = planterjson.data[i].plname;
          String? traflag = planterjson.data[i].traflag;
          var x = Planter(plid, plcode, plname, traflag);
          // await DBHelper.insertPlanter(x.toMap());
          batch.insert(
            planterTable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.20, 'Processing planter sources...');
        plantersourcejson = PlanterSourceFromJson(response.body);
        for (var i = 0; i < plantersourcejson.data.length; i++) {
          int? plsourceId = int.parse(plantersourcejson.data[i].plsource_id);
          String? plsourceCode = plantersourcejson.data[i].plsource_code;
          String? plsourceName = plantersourcejson.data[i].plsource_name;
          String? traflag = plantersourcejson.data[i].traflag;
          var x = SourcePlanter(
            plsourceId,
            plsourceCode,
            plsourceName,
            traflag,
          );
          // await DBHelper.insertSourcePlanter(y.toMap());
          batch.insert(
            srcplanterTable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        _updateProgress(0.25, 'Processing Lot Codes...');
        lotcodejson = LotCodeFromJson(response.body);
        for (var i = 0; i < lotcodejson.data.length; i++) {
          int? lotcodeid = int.parse(lotcodejson.data[i].lotcodeid);
          String? lotcodename = lotcodejson.data[i].lotcodename;
          int? plantersrcId = int.parse(lotcodejson.data[i].plantersrcId);
          String? traflag = lotcodejson.data[i].traflag;
          var x = Lots(lotcodeid, lotcodename, plantersrcId, traflag);
          // await DBHelper.insertSourcePlanter(y.toMap());
          batch.insert(
            lotcodeTable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.30, 'Processing requests...');
        requestsjson = RequestFromJson(response.body);
        for (var i = 0; i < requestsjson.data.length; i++) {
          int? requestId = int.parse(requestsjson.data[i].request_id);
          int? requestNo = int.parse(requestsjson.data[i].request_no);
          String? requestDate = requestsjson.data[i].request_date;
          String? plCode = requestsjson.data[i].pl_code;
          String? plName = requestsjson.data[i].pl_name;
          String? location = requestsjson.data[i].location;
          String? area = requestsjson.data[i].area;
          int? qty = double.parse(requestsjson.data[i].qty).toInt();
          int? remainingQty = double.parse(
            requestsjson.data[i].remaining_qty,
          ).toInt();
          int? deliveredQty = double.parse(
            requestsjson.data[i].delivered_qty,
          ).toInt();
          int? plid = int.parse(requestsjson.data[i].plid);
          int? forcpr = int.parse(requestsjson.data[i].forcpr);
          String traflag = requestsjson.data[i].traflag;
          var x = Requests(
            requestId,
            requestNo,
            requestDate,
            plCode,
            plName,
            location,
            area,
            qty,
            remainingQty,
            deliveredQty,
            plid,
            forcpr,
            traflag,
          );
          // await DBHelper.insertReq(xx.toMap());
          batch.insert(
            requestTable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.40, 'Processing coordinators...');
        coordinatorjson = CoordinatorFromJson(response.body);
        for (var i = 0; i < coordinatorjson.data.length; i++) {
          int? id = int.parse(coordinatorjson.data[i].fr_id);
          String? frCode = coordinatorjson.data[i].fr_code;
          String? frName = coordinatorjson.data[i].fr_name;
          String? traflag = coordinatorjson.data[i].traflag;
          var x = Coordinators(id, frCode, frName, traflag);
          // await DBHelper.insertCoords(yy.toMap());
          batch.insert(
            frTable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.50, 'Processing cutters...');
        cuttersjson = CutterFromJson(response.body);
        for (var i = 0; i < cuttersjson.data.length; i++) {
          int? id = int.parse(cuttersjson.data[i].id);
          String? description = cuttersjson.data[i].description;
          String? traflag = cuttersjson.data[i].traflag;
          var x = Cutters(id, description, traflag);
          // await DBHelper.insertCutter(yy.toMap());
          batch.insert(
            cuttertable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.60, 'Processing varieties...');
        varietyjson = VarietyFromJson(response.body);
        for (var i = 0; i < varietyjson.data.length; i++) {
          int? id = int.parse(varietyjson.data[i].id);
          String? description = varietyjson.data[i].description;
          String? traflag = varietyjson.data[i].traflag;
          var x = Variety(id, description, traflag);
          // await DBHelper.insertVariety(yy.toMap());
          batch.insert(
            varietytable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.70, 'Processing locations...');
        locationsjson = SrcLocationFromJson(response.body);
        for (var i = 0; i < locationsjson.data.length; i++) {
          int? id = int.parse(locationsjson.data[i].id);
          String? location = locationsjson.data[i].location;
          String? code = locationsjson.data[i].code;
          String? traflag = locationsjson.data[i].traflag;
          var x = Location(id, code, location, traflag);
          // await DBHelper.insertLocation(yy.toMap());
          batch.insert(
            locationtable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        _updateProgress(0.85, 'Processing Cutting Mode records...');
        cmjson = CMFromJson(response.body);
        for (var i = 0; i < cmjson.data.length; i++) {
          int id = int.parse(cmjson.data[i].id);
          String desc = cmjson.data[i].description;
          String traflag = cmjson.data[i].traflag;

          final x = Cutting(id, desc, traflag);
          // await DBHelper.insertCM(cm.toMap());
          batch.insert(
            cuttingmodetable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.90, 'Processing user permission...');
        permissionsJson = PermissionsFromJson(response.body);
        for (var i = 0; i < permissionsJson.data.length; i++) {
          int? moduleid = int.parse(permissionsJson.data[i].moduleid);
          int? hasaccess = int.parse(permissionsJson.data[i].hasaccess);
          var x = UserPermissions(moduleid, hasaccess);
          // await DBHelper.insertUserpermission(xx.toMap());
          batch.insert(
            userpermissionstable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.95, 'Processing CPR records...');
        cprjson = CprFromJson(response.body);
        for (var i = 0; i < cprjson.data.length; i++) {
          int id = int.parse(cprjson.data[i].id);
          int cprId = int.parse(cprjson.data[i].id);
          String? cprRefno = cprjson.data[i].cpr_refno;
          int? requestId = int.parse(cprjson.data[i].request_id);
          int? locationId = int.parse(cprjson.data[i].location_id);
          int? varietyId = int.parse(cprjson.data[i].variety_id);
          int? planterId = int.parse(cprjson.data[i].planter_id);
          int? cutterId = int.parse(cprjson.data[i].cutter_id);
          int? qty = int.parse(cprjson.data[i].qty);
          String? deliveryDate = cprjson.data[i].delivery_date;
          int? deliveredById = int.parse(cprjson.data[i].delivered_by_id);
          String? recievedBy = cprjson.data[i].recieved_by;
          int? series = int.parse(cprjson.data[i].series);
          int? sourcePlanter = int.parse(cprjson.data[i].source_planter);
          String? traflag = cprjson.data[i].traflag;
          int? printCount =
              int.tryParse(cprjson.data[i].print_count ?? '0') ?? 0;
          int? rcvfrId = int.tryParse(cprjson.data[i].rcvfr_id ?? '0') ?? 0;
          int? haulingPaid =
              (double.tryParse(cprjson.data[i].hauling_paid ?? '0') ?? 0)
                  .toInt();

          int? haulingAmount =
              (double.tryParse(cprjson.data[i].hauling_amount ?? '0') ?? 0.0)
                  .toInt();

          int? cuttingmode =
              int.tryParse(cprjson.data[i].cuttingmode ?? '0') ?? 0;

          String? cuttingdate = cprjson.data[i].cuttingdate;

          int? cuttingPaid =
              (double.tryParse(cprjson.data[i].cutting_paid ?? '0') ?? 0.0)
                  .toInt();

          int? cuttingAmount =
              (double.tryParse(cprjson.data[i].cutting_amount ?? '0') ?? 0.0)
                  .toInt();

          int? sacksPaid =
              (double.tryParse(cprjson.data[i].sacks_paid ?? '0') ?? 0.0)
                  .toInt();

          int? sacksAmount =
              (double.tryParse(cprjson.data[i].sacks_amount ?? '0') ?? 0.0)
                  .toInt();

          int? othersPaid =
              (double.tryParse(cprjson.data[i].others_paid ?? '0') ?? 0.0)
                  .toInt();

          int? othersAmount =
              (double.tryParse(cprjson.data[i].others_amount ?? '0') ?? 0.0)
                  .toInt();
          String? lotCode = cprjson.data[i].lot_code;
          download_cpr_Image(id, cprRefno);
          var x = CPR(
            cprId,
            cprRefno,
            requestId,
            locationId,
            varietyId,
            planterId,
            cutterId,
            qty,
            deliveryDate,
            printCount,
            deliveredById,
            recievedBy,
            series,
            sourcePlanter,
            traflag,
            rcvfrId,
            haulingPaid,
            haulingAmount,
            cuttingmode,
            cuttingdate,
            cuttingPaid,
            cuttingAmount,
            sacksPaid,
            sacksAmount,
            othersPaid,
            othersAmount,
            lotCode,
          );
          // await DBHelper.insertCPR(yy.toMap());
          batch.insert(
            cprtable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        _updateProgress(0.90, 'Processing Lot pics...');
        lotpicturesjson = LotPictureFromJson(response.body);
        for (var i = 0; i < lotpicturesjson.data.length; i++) {
          int? collpid = int.parse(lotpicturesjson.data[i].collpid);
          String? collpreqid = lotpicturesjson.data[i].collpreqid;
          String? collandprep = lotpicturesjson.data[i].collandprep;
          String? collandprepdate = lotpicturesjson.data[i].collandprepdate;
          String? collandactualdate = lotpicturesjson.data[i].collandactualdate;
          String? collandactual = lotpicturesjson.data[i].collandactual;
          String? collptraflag = lotpicturesjson.data[i].collptraflag;
          String? colaptraflag = lotpicturesjson.data[i].colaptraflag;
          // String? collandtraflag = lotpicturesjson.data[i].collandtraflag;
          var x = LotPicture(
            collpid,
            collpreqid,
            collandprep,
            collandprepdate,
            collandactual,
            collandactualdate,
            collptraflag,
            colaptraflag,
            // collandtraflag,
          );
          download_lp_Image(collpid, collpreqid ?? '');
          batch.insert(
            lotPicturesTable,
            x.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
        _updateProgress(1.0, 'Sync completed!');
        DataNotifier.instance.notify();
        return true;
      } else if (response.statusCode == 401) {
        _updateProgress(0, 'Authentication failed');
        return false;
      } else {
        _updateProgress(0, 'Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _updateProgress(0, _friendlyError(e));
      return false;
    }
  }

  // Future<bool?> savesync(
  //   context,
  //   conntype,
  //   List<Map<String, dynamic>> cprlist,
  //   List<Map<String, dynamic>> lplist,
  // ) async {
  //   ApiConstants.conntype = conntype;
  //   final apiEndpoint = '${ApiConstants.baseUrl}/${ApiConstants.syncUpdate}';

  //   _updateProgress(0.05, 'Preparing data...');

  //   List<dynamic> jsonCprList = cprlist.map((row) {
  //     String cleanDate = (row['delivery_date'] ?? '')
  //         .toString()
  //         .replaceFirst('T', ' ')
  //         .split('.')[0];

  //     return ({
  //       'id': row['cpr_id'] ?? 0,
  //       'ref_no': row['cpr_refno'] ?? 0,
  //       'request_id': row['request_id'] ?? 0,
  //       'lo_id_source': row['location_id'] ?? 0,
  //       'variety_id': row['variety_id'] ?? 0,
  //       'pl_id': row['planter_id'],
  //       'cutter_id': row['cutter_id'] ?? 0,
  //       'qty': row['qty'],
  //       'delivery_date': cleanDate,
  //       'fr_id': row['rcvfr_id'] ?? 0,
  //       'printcount': row['print_count'] ?? 0,
  //       'pl_id_source': row['source_planter'] ?? 0,
  //       'received_by': row['recieved_by'],
  //       'series': row['series'],
  //       'traflag': row['traflag'],
  //       'hauling_paid': row['hauling_paid'] ?? 0,
  //       'hauling_amount': row['hauling_amount'] ?? 0,
  //       'cuttingmode': row['cuttingmode'] ?? 0,
  //       'cuttingdate': (row['cuttingdate'] ?? '')
  //           .toString()
  //           .replaceFirst('T', ' ')
  //           .split('.')[0],
  //     });
  //   }).toList();

  //   List<dynamic> jsonLpList = lplist
  //       .where((row) {
  //         final lpTraflag = (row['lp_traflag'] ?? 'E').toString();
  //         final apTraflag = (row['ap_traflag'] ?? 'E').toString();
  //         return !(lpTraflag == 'S' && apTraflag == 'S');
  //       })
  //       .map((row) {
  //         String rawApTraflag = row['ap_traflag'] ?? 'E';
  //         String rawLpTraflag = row['lp_traflag'] ?? 'E';

  //         String apTraflag = rawApTraflag == 'A' ? 'S' : rawApTraflag;
  //         String lpTraflag = rawLpTraflag == 'A' ? 'S' : rawLpTraflag;

  //         String cleanlpDate = rawLpTraflag != 'E'
  //             ? (row['landprep_date'] ?? '')
  //                   .toString()
  //                   .replaceFirst('T', ' ')
  //                   .split('.')[0]
  //             : '';
  //         String cleanapDate = rawApTraflag != 'E'
  //             ? (row['actualplanted_date'] ?? '')
  //                   .toString()
  //                   .replaceFirst('T', ' ')
  //                   .split('.')[0]
  //             : '';

  //         return ({
  //           'id': row['id'] ?? 0,
  //           'request_id': row['request_id'] ?? 0,
  //           // 'land_prep': cleanLp,
  //           'landprep_date': cleanlpDate,
  //           // 'actual_planted': cleanAp,
  //           'actualplanted_date': cleanapDate,
  //           'ap_traflag': apTraflag,
  //           'lp_traflag': lpTraflag,
  //         });
  //       })
  //       .toList();

  //   final uri = Uri.parse(apiEndpoint);
  //   final request = http.MultipartRequest('POST', uri);

  //   request.headers[HttpHeaders.authorizationHeader] = globals.globalhttpauth
  //       .toString();

  //   request.fields['usernameid'] = globals.globalusernameid.toString();
  //   request.fields['cprinfo'] = jsonEncode(jsonCprList);
  //   request.fields['splotpictures'] = jsonEncode(jsonLpList);

  //   for (final row in cprlist) {
  //     final id = (row['cpr_id'] ?? '').toString();

  //     await _addImageFilePart(request, row['signature'], 'sig_$id');
  //     await _addImageFilePart(request, row['image'], 'pic_$id');
  //     await _addImageFilePart(request, row['sp_delivered'], 'spd_$id');
  //   }

  //   final uploadableLp = lplist.where((row) {
  //     final lp = (row['lp_traflag'] ?? 'E').toString();
  //     final ap = (row['ap_traflag'] ?? 'E').toString();
  //     return !(lp == 'S' && ap == 'S');
  //   }).toList();

  //   for (final row in uploadableLp) {
  //     final id = (row['id'] ?? '').toString();
  //     final rawLp = (row['lp_traflag'] ?? 'E').toString();
  //     final rawAp = (row['ap_traflag'] ?? 'E').toString();

  //     if (rawLp == 'A')
  //       await _addImageFilePart(request, row['land_prep'], 'lp_$id');
  //     if (rawAp == 'A')
  //       await _addImageFilePart(request, row['actual_planted'], 'ap_$id');
  //   }

  //   Planterjson planterjson = Planterjson(data: []);
  //   PlanterSourcejson plantersourcejson = PlanterSourcejson(data: []);
  //   Cutterjson cuttersjson = Cutterjson(data: []);
  //   SrcLocationjson locationsjson = SrcLocationjson(data: []);
  //   Varietyjson varietyjson = Varietyjson(data: []);
  //   Requestjson requestsjson = Requestjson(data: []);
  //   Coordinatorjson coordinatorjson = Coordinatorjson(data: []);
  //   LotPictureJson lotpicturesjson = LotPictureJson(data: []);
  //   PermissionsJson permissionsJson = PermissionsJson(data: []);

  //   try {
  //     _updateProgress(0.10, 'Uploading to server...');
  //     print('=== SAVESYNC DEBUG START ===');
  //     print('URL: $apiEndpoint');
  //     print('AUTH: ${globals.globalhttpauth}');
  //     print('usernameid: ${globals.globalusernameid}');
  //     print('cprinfo count: ${jsonCprList.length}');
  //     print('splotpictures count: ${jsonLpList.length}');
  //     print('cprinfo json: ${jsonEncode(jsonCprList)}');
  //     print('splotpictures json: ${jsonEncode(jsonLpList)}');

  //     for (final f in request.files) {
  //       print(
  //         'FILE FIELD: ${f.field} | NAME: ${f.filename} | LENGTH: ${f.length}',
  //       );
  //     }

  //     print('FIELDS: ${request.fields}');
  //     print('=== SAVESYNC DEBUG END ===');
  //     final streamed = await request.send().timeout(
  //       const Duration(seconds: 30),
  //     );
  //     final response = await http.Response.fromStream(streamed);

  //     print('STATUS: ${response.statusCode}');
  //     print('BODY: ${response.body}');

  //     if (response.statusCode == 200) {
  //       _updateProgress(0.15, 'Updating local records...');

  //       final db = await DBHelper.db;
  //       final batch = db.batch();

  //       // Bulk-update traflag for already-synced records (single queries, no loop)
  //       await db.update(
  //         cprtable,
  //         {colcprtraflag: 'S'},
  //         where: '$colcprtraflag = ? OR $colcprtraflag = ?',
  //         whereArgs: ['A', 'U'],
  //       );
  //       await db.update(
  //         lotPicturesTable,
  //         {collptraflag: 'S'},
  //         where: '$collptraflag = ?',
  //         whereArgs: ['A'],
  //       );
  //       await db.update(
  //         lotPicturesTable,
  //         {colaptraflag: 'S'},
  //         where: '$colaptraflag = ?',
  //         whereArgs: ['A'],
  //       );

  //       _updateProgress(0.20, 'Processing planters...');
  //       planterjson = plantersFromJson(response.body);
  //       for (var i = 0; i < planterjson.data.length; i++) {
  //         int? plid = int.parse(planterjson.data[i].plid);
  //         String? plcode = planterjson.data[i].plcode;
  //         String? plname = planterjson.data[i].plname;
  //         String? traflag = planterjson.data[i].traflag;
  //         var x = Planter(plid, plcode, plname, traflag);
  //         batch.insert(
  //           planterTable,
  //           x.toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );
  //       }

  //       _updateProgress(0.20, 'Processing planter sources...');
  //       plantersourcejson = PlanterSourceFromJson(response.body);
  //       for (var i = 0; i < plantersourcejson.data.length; i++) {
  //         int? plsourceId = int.parse(plantersourcejson.data[i].plsource_id);
  //         String? plsourceCode = plantersourcejson.data[i].plsource_code;
  //         String? plsourceName = plantersourcejson.data[i].plsource_name;
  //         String? traflag = plantersourcejson.data[i].traflag;
  //         var y = SourcePlanter(
  //           plsourceId,
  //           plsourceCode,
  //           plsourceName,
  //           traflag,
  //         );
  //         if (traflag == 'I') {
  //           batch.insert(
  //             srcplanterTable,
  //             y.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (traflag == 'U') {
  //           batch.update(
  //             srcplanterTable,
  //             y.toMap(),
  //             where: '$colPlsrcid = ?',
  //             whereArgs: [plsourceId],
  //           );
  //         } else if (traflag == 'D') {
  //           batch.delete(
  //             srcplanterTable,
  //             where: '$colPlsrcid = ?',
  //             whereArgs: [plsourceId],
  //           );
  //         }
  //       }

  //       _updateProgress(0.30, 'Processing requests...');
  //       requestsjson = RequestFromJson(response.body);
  //       for (var i = 0; i < requestsjson.data.length; i++) {
  //         int? requestId = int.parse(requestsjson.data[i].request_id);
  //         int? requestNo = int.parse(requestsjson.data[i].request_no);
  //         String? requestDate = requestsjson.data[i].request_date;
  //         String? plCode = requestsjson.data[i].pl_code;
  //         String? plName = requestsjson.data[i].pl_name;
  //         String? location = requestsjson.data[i].location;
  //         String? area = requestsjson.data[i].area;
  //         int? qty = double.parse(requestsjson.data[i].qty).toInt();
  //         int? remainingQty = double.parse(
  //           requestsjson.data[i].remaining_qty,
  //         ).toInt();
  //         int? deliveredQty = double.parse(
  //           requestsjson.data[i].delivered_qty,
  //         ).toInt();
  //         int? plid = int.parse(requestsjson.data[i].plid);
  //         String traflag = requestsjson.data[i].traflag;
  //         var xx = Requests(
  //           requestId,
  //           requestNo,
  //           requestDate,
  //           plCode,
  //           plName,
  //           location,
  //           area,
  //           qty,
  //           remainingQty,
  //           deliveredQty,
  //           plid,
  //           traflag,
  //         );
  //         if (traflag == 'I') {
  //           batch.insert(
  //             requestTable,
  //             xx.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (traflag == 'U') {
  //           batch.update(
  //             requestTable,
  //             xx.toMap(),
  //             where: '$colReqid = ?',
  //             whereArgs: [requestId],
  //           );
  //         } else if (traflag == 'D') {
  //           batch.delete(
  //             requestTable,
  //             where: '$colReqid = ?',
  //             whereArgs: [requestId],
  //           );
  //         }
  //       }

  //       _updateProgress(0.40, 'Processing coordinators...');
  //       coordinatorjson = CoordinatorFromJson(response.body);
  //       for (var i = 0; i < coordinatorjson.data.length; i++) {
  //         int? id = int.parse(coordinatorjson.data[i].fr_id);
  //         String? frCode = coordinatorjson.data[i].fr_code;
  //         String? frName = coordinatorjson.data[i].fr_name;
  //         String? traflag = coordinatorjson.data[i].traflag;
  //         var yy = Coordinators(id, frCode, frName, traflag);
  //         if (traflag == 'I') {
  //           batch.insert(
  //             frTable,
  //             yy.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (traflag == 'U') {
  //           batch.update(
  //             frTable,
  //             yy.toMap(),
  //             where: '$colfrid = ?',
  //             whereArgs: [id],
  //           );
  //         } else if (traflag == 'D') {
  //           batch.delete(frTable, where: '$colfrid = ?', whereArgs: [id]);
  //         }
  //       }

  //       _updateProgress(0.50, 'Processing cutters...');
  //       cuttersjson = CutterFromJson(response.body);
  //       for (var i = 0; i < cuttersjson.data.length; i++) {
  //         int? id = int.parse(cuttersjson.data[i].id);
  //         String? description = cuttersjson.data[i].description;
  //         String? traflag = cuttersjson.data[i].traflag;
  //         var yy = Cutters(id, description, traflag);
  //         if (traflag == 'I') {
  //           batch.insert(
  //             cuttertable,
  //             yy.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (traflag == 'U') {
  //           batch.update(
  //             cuttertable,
  //             yy.toMap(),
  //             where: '$colctrid = ?',
  //             whereArgs: [id],
  //           );
  //         } else if (traflag == 'D') {
  //           batch.delete(cuttertable, where: '$colctrid = ?', whereArgs: [id]);
  //         }
  //       }

  //       _updateProgress(0.70, 'Processing varieties...');
  //       varietyjson = VarietyFromJson(response.body);
  //       for (var i = 0; i < varietyjson.data.length; i++) {
  //         int? id = int.parse(varietyjson.data[i].id);
  //         String? description = varietyjson.data[i].description;
  //         String? traflag = varietyjson.data[i].traflag;
  //         var yy = Variety(id, description, traflag);
  //         if (traflag == 'I') {
  //           batch.insert(
  //             varietytable,
  //             yy.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (traflag == 'U') {
  //           batch.update(
  //             varietytable,
  //             yy.toMap(),
  //             where: '$colvarid = ?',
  //             whereArgs: [id],
  //           );
  //         } else if (traflag == 'D') {
  //           batch.delete(varietytable, where: '$colvarid = ?', whereArgs: [id]);
  //         }
  //       }

  //       _updateProgress(0.80, 'Processing locations...');
  //       locationsjson = SrcLocationFromJson(response.body);
  //       for (var i = 0; i < locationsjson.data.length; i++) {
  //         int? id = int.parse(locationsjson.data[i].id);
  //         String? location = locationsjson.data[i].location;
  //         String? code = locationsjson.data[i].code;
  //         String? traflag = locationsjson.data[i].traflag;
  //         var yy = Location(id, location, code, traflag);
  //         if (traflag == 'I') {
  //           batch.insert(
  //             locationtable,
  //             yy.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (traflag == 'U') {
  //           batch.update(
  //             locationtable,
  //             yy.toMap(),
  //             where: '$collocid = ?',
  //             whereArgs: [id],
  //           );
  //         } else if (traflag == 'D') {
  //           batch.delete(
  //             locationtable,
  //             where: '$collocid = ?',
  //             whereArgs: [id],
  //           );
  //         }
  //       }

  //       _updateProgress(0.90, 'Processing permissions...');
  //       permissionsJson = PermissionsFromJson(response.body);
  //       for (var i = 0; i < permissionsJson.data.length; i++) {
  //         int? moduleid = int.parse(permissionsJson.data[i].moduleid);
  //         int? hasaccess = int.parse(permissionsJson.data[i].hasaccess);
  //         var xx = UserPermissions(moduleid, hasaccess);
  //         batch.insert(
  //           userpermissionstable,
  //           xx.toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );
  //       }

  //       _updateProgress(0.90, 'Processing Lot pics...');
  //       lotpicturesjson = LotPictureFromJson(response.body);
  //       for (var i = 0; i < lotpicturesjson.data.length; i++) {
  //         int? collpid = int.parse(lotpicturesjson.data[i].collpid);
  //         String? collpreqid = lotpicturesjson.data[i].collpreqid;
  //         String? collandprep = lotpicturesjson.data[i].collandprep;
  //         String? collandprepdate = lotpicturesjson.data[i].collandprepdate;
  //         String? collandactualdate = lotpicturesjson.data[i].collandactualdate;
  //         String? collandactual = lotpicturesjson.data[i].collandactual;
  //         String? collptraflag = lotpicturesjson.data[i].collptraflag;
  //         String? colaptraflag = lotpicturesjson.data[i].colaptraflag;
  //         // String? collandtraflag = lotpicturesjson.data[i].collandtraflag;
  //         var yy = LotPicture(
  //           collpid,
  //           collpreqid,
  //           collandprep,
  //           collandprepdate,
  //           collandactual,
  //           collandactualdate,
  //           collptraflag,
  //           colaptraflag,
  //         );
  //         if (collptraflag == 'I' || colaptraflag == 'I') {
  //           batch.insert(
  //             lotPicturesTable,
  //             yy.toMap(),
  //             conflictAlgorithm: ConflictAlgorithm.replace,
  //           );
  //         } else if (collptraflag == 'U' || colaptraflag == 'U') {
  //           batch.update(
  //             lotPicturesTable,
  //             yy.toMap(),
  //             where: '$collpid = ?',
  //             whereArgs: [collpid],
  //           );
  //         } else if (collptraflag == 'D' || colaptraflag == 'D') {
  //           batch.delete(
  //             lotPicturesTable,
  //             where: '$collpid = ?',
  //             whereArgs: [collpid],
  //           );
  //         }
  //       }

  //       await batch.commit(noResult: true);
  //       DataNotifier.instance.notify();

  //       _updateProgress(1.0, 'Sync completed!');
  //       return true;
  //     } else if (response.statusCode == 401) {
  //       _updateProgress(0, 'Authentication failed');
  //       return false;
  //     } else {
  //       _updateProgress(0, 'Server error: ${response.body}');
  //       print('${response.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     _updateProgress(0, _friendlyError(e));
  //     return false;
  //   }
  // }

  // Future<bool?> savesync(
  //   context,
  //   conntype,
  //   List<Map<String, dynamic>> cprlist,
  //   List<Map<String, dynamic>> lplist,
  // ) async {
  //   ApiConstants.conntype = conntype;
  //   final apiEndpoint = '${ApiConstants.baseUrl}/${ApiConstants.syncUpdate}';
  //   final uri = Uri.parse(apiEndpoint);
  //   final db = await DBHelper.db;

  //   try {
  //     // --- PHASE 1: SYNC CPR RECORDS (Individual Uploads) ---
  //     for (int i = 0; i < cprlist.length; i++) {
  //       var row = cprlist[i];
  //       final cprId = (row['cpr_id'] ?? '').toString();

  //       _updateProgress(
  //         0.10 + (i / cprlist.length * 0.40),
  //         'Uploading CPR $cprId...',
  //       );

  //       final request = http.MultipartRequest('POST', uri);
  //       request.headers[HttpHeaders.authorizationHeader] = globals
  //           .globalhttpauth
  //           .toString();
  //       request.fields['usernameid'] = globals.globalusernameid.toString();

  //       // Single record mapping
  //       String cleanDate = (row['delivery_date'] ?? '')
  //           .toString()
  //           .replaceFirst('T', ' ')
  //           .split('.')[0];
  //       request.fields['cprinfo'] = jsonEncode([
  //         {
  //           'id': row['cpr_id'] ?? 0,
  //           'ref_no': row['cpr_refno'] ?? 0,
  //           'request_id': row['request_id'] ?? 0,
  //           'lo_id_source': row['location_id'] ?? 0,
  //           'variety_id': row['variety_id'] ?? 0,
  //           'pl_id': row['planter_id'],
  //           'cutter_id': row['cutter_id'] ?? 0,
  //           'qty': row['qty'],
  //           'delivery_date': cleanDate,
  //           'fr_id': row['rcvfr_id'] ?? 0,
  //           'printcount': row['print_count'] ?? 0,
  //           'pl_id_source': row['source_planter'] ?? 0,
  //           'received_by': row['recieved_by'],
  //           'series': row['series'],
  //           'traflag': row['traflag'],
  //           'hauling_paid': row['hauling_paid'] ?? 0,
  //           'hauling_amount': row['hauling_amount'] ?? 0,
  //           'cuttingmode': row['cuttingmode'] ?? 0,
  //           'cuttingdate': row['cuttingdate'] ?? '0',
  //         },
  //       ]);

  //       await _addImageFilePart(request, row['signature'], 'sig_$cprId');
  //       await _addImageFilePart(request, row['image'], 'pic_$cprId');
  //       await _addImageFilePart(request, row['sp_delivered'], 'spd_$cprId');
  //       print('Total Request Size: ${(request.fields)} ');
  //       final response = await http.Response.fromStream(
  //         await request.send().timeout(const Duration(minutes: 2)),
  //       );

  //       print(response.body);
  //       if (response.statusCode == 200) {
  //         await db.update(
  //           cprtable,
  //           {colcprtraflag: 'S'},
  //           where: 'cpr_id = ?',
  //           whereArgs: [row['cpr_id']],
  //         );
  //       } else {
  //         throw 'Failed to upload CPR $cprId (Status: ${response.statusCode})';
  //       }
  //     }

  //     // --- PHASE 2: SYNC LOT PICTURES (Individual Uploads) ---
  //     final uploadableLp = lplist
  //         .where(
  //           (row) =>
  //               !((row['lp_traflag'] ?? 'E') == 'S' &&
  //                   (row['ap_traflag'] ?? 'E') == 'S'),
  //         )
  //         .toList();

  //     for (int i = 0; i < uploadableLp.length; i++) {
  //       var row = uploadableLp[i];
  //       final lpId = (row['id'] ?? '').toString();
  //       _updateProgress(
  //         0.50 + (i / uploadableLp.length * 0.20),
  //         'Uploading Lot Pic $lpId...',
  //       );

  //       final request = http.MultipartRequest('POST', uri);
  //       request.headers[HttpHeaders.authorizationHeader] = globals
  //           .globalhttpauth
  //           .toString();
  //       request.fields['usernameid'] = globals.globalusernameid.toString();

  //       request.fields['splotpictures'] = jsonEncode([
  //         {
  //           'id': row['id'] ?? 0,
  //           'request_id': row['request_id'] ?? 0,
  //           'landprep_date': row['lp_traflag'] != 'E'
  //               ? (row['landprep_date'] ?? '')
  //                     .toString()
  //                     .replaceFirst('T', ' ')
  //                     .split('.')[0]
  //               : '',
  //           'actualplanted_date': row['ap_traflag'] != 'E'
  //               ? (row['actualplanted_date'] ?? '')
  //                     .toString()
  //                     .replaceFirst('T', ' ')
  //                     .split('.')[0]
  //               : '',
  //           'ap_traflag': row['ap_traflag'] == 'A' ? 'S' : row['ap_traflag'],
  //           'lp_traflag': row['lp_traflag'] == 'A' ? 'S' : row['lp_traflag'],
  //         },
  //       ]);

  //       if (row['lp_traflag'] == 'A')
  //         await _addImageFilePart(request, row['land_prep'], 'lp_$lpId');
  //       if (row['ap_traflag'] == 'A')
  //         await _addImageFilePart(request, row['actual_planted'], 'ap_$lpId');

  //       final response = await http.Response.fromStream(
  //         await request.send().timeout(const Duration(minutes: 2)),
  //       );

  //       if (response.statusCode == 200) {
  //         await db.update(
  //           lotPicturesTable,
  //           {collptraflag: 'S', colaptraflag: 'S'},
  //           where: 'id = ?',
  //           whereArgs: [row['id']],
  //         );
  //       }
  //     }

  //     // --- PHASE 3: MASTER DATA DOWNLOAD & BATCH PROCESSING ---
  //     _updateProgress(0.80, 'Downloading updated master data...');
  //     final finalReq = await http.post(
  //       uri,
  //       body: {'usernameid': globals.globalusernameid.toString()},
  //       headers: {
  //         HttpHeaders.authorizationHeader: globals.globalhttpauth.toString(),
  //       },
  //     );

  //     if (finalReq.statusCode == 200) {
  //       final batch = db.batch();
  //       final body = finalReq.body;

  //       _updateProgress(0.85, 'Processing Master Data...');

  //       // Batch process each category
  //       final planters = plantersFromJson(body);
  //       for (var p in planters.data)
  //         batch.insert(
  //           planterTable,
  //           Planter(int.parse(p.plid), p.plcode, p.plname, p.traflag).toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );

  //       final requests = RequestFromJson(body);
  //       for (var r in requests.data)
  //         batch.insert(
  //           requestTable,
  //           Requests(
  //             int.parse(r.request_id),
  //             int.parse(r.request_no),
  //             r.request_date,
  //             r.pl_code,
  //             r.pl_name,
  //             r.location,
  //             r.area,
  //             double.parse(r.qty).toInt(),
  //             double.parse(r.remaining_qty).toInt(),
  //             double.parse(r.delivered_qty).toInt(),
  //             int.parse(r.plid),
  //             r.traflag,
  //           ).toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );

  //       final coordinators = CoordinatorFromJson(body);
  //       for (var c in coordinators.data)
  //         batch.insert(
  //           frTable,
  //           Coordinators(
  //             int.parse(c.fr_id),
  //             c.fr_code,
  //             c.fr_name,
  //             c.traflag,
  //           ).toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );

  //       final varieties = VarietyFromJson(body);
  //       for (var v in varieties.data)
  //         batch.insert(
  //           varietytable,
  //           Variety(int.parse(v.id), v.description, v.traflag).toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );

  //       final perms = PermissionsFromJson(body);
  //       for (var p in perms.data)
  //         batch.insert(
  //           userpermissionstable,
  //           UserPermissions(
  //             int.parse(p.moduleid),
  //             int.parse(p.hasaccess),
  //           ).toMap(),
  //           conflictAlgorithm: ConflictAlgorithm.replace,
  //         );

  //       await batch.commit(noResult: true);
  //       DataNotifier.instance.notify();
  //       _updateProgress(1.0, 'Sync Completed');
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     _updateProgress(0, 'Sync Failed: $e');
  //     return false;
  //   }
  // }

  Future<bool?> savesync(
    context,
    conntype,
    List<Map<String, dynamic>> cprlist,
    List<Map<String, dynamic>> lplist,
  ) async {
    ApiConstants.conntype = conntype;
    final apiEndpoint = '${ApiConstants.baseUrl}/${ApiConstants.syncUpdate}';
    final uri = Uri.parse(apiEndpoint);
    final db = await DBHelper.db;

    // --- PRE-CHECK: FILTER UPLOADABLE RECORDS ---
    final uploadableLp = lplist
        .where(
          (row) =>
              !((row['lp_traflag'] ?? 'E') == 'S' &&
                  (row['ap_traflag'] ?? 'E') == 'S'),
        )
        .toList();

    // If nothing to upload, we can skip straight to master data or exit
    if (cprlist.isEmpty && uploadableLp.isEmpty) {
      _updateProgress(
        0.1,
        'No local records to upload. Checking for updates...',
      );
    }

    try {
      // --- PHASE 1: SYNC CPR RECORDS (Individual Uploads) ---
      for (int i = 0; i < cprlist.length; i++) {
        var row = cprlist[i];
        final cprId = (row['cpr_id'] ?? '').toString();

        _updateProgress(
          0.10 + (i / cprlist.length * 0.40),
          'Uploading CPR $cprId...',
        );

        final request = http.MultipartRequest('POST', uri);
        request.headers[HttpHeaders.authorizationHeader] = globals
            .globalhttpauth
            .toString();
        request.fields['usernameid'] = globals.globalusernameid.toString();

        // Mapping logic with null-safety
        String cleanDate = (row['delivery_date'] ?? '')
            .toString()
            .replaceFirst('T', ' ')
            .split('.')[0];
        request.fields['cprinfo'] = jsonEncode([
          {
            'id': row['cpr_id'] ?? 0,
            'ref_no': row['cpr_refno'] ?? 0,
            'request_id': row['request_id'] ?? 0,
            'lo_id_source': row['location_id'] ?? 0,
            'variety_id': row['variety_id'] ?? 0,
            'pl_id': row['planter_id'],
            'cutter_id': row['cutter_id'] ?? 0,
            'qty': row['qty'],
            'delivery_date': cleanDate,
            'fr_id': row['rcvfr_id'] ?? 0,
            'printcount': row['print_count'] ?? 0,
            'pl_id_source': row['source_planter'] ?? 0,
            'received_by': row['recieved_by'],
            'series': row['series'],
            'traflag': row['traflag'],
            'hauling_paid': row['hauling_paid'] ?? 0,
            'hauling_amount': row['hauling_amount'] ?? 0,
            'cutting_paid': row['cutting_paid'] ?? 0,
            'cutting_amount': row['cutting_amount'] ?? 0,
            'sacks_paid': row['sacks_paid'] ?? 0,
            'sacks_amount': row['sacks_amount'] ?? 0,
            'others_paid': row['others_paid'] ?? 0,
            'others_amount': row['others_amount'] ?? 0,
            'lot_code': row['lot_code'] ?? 0,
            'cuttingmode': row['cuttingmode'] ?? 0,
            'cuttingdate': row['cuttingdate'] ?? '0',
          },
        ]);

        final String cprNo = (row['cpr_refno'] ?? '').toString();

        final String sigFileName = 'sig_$cprNo.jpg';
        final String picFileName = 'pic_$cprNo.jpg';
        final String spdFileName = 'spd_$cprNo.jpg';

        final String sigPath =
            '//storage/emulated/0/DCIM/CPR_IMAGES/$sigFileName';
        final String picPath =
            '//storage/emulated/0/DCIM/CPR_IMAGES/$picFileName';
        final String spdPath =
            '//storage/emulated/0/DCIM/CPR_IMAGES/$spdFileName';

        await _addImageFilePart(request, sigPath, 'sig_$cprId');
        await _addImageFilePart(request, picPath, 'pic_$cprId');
        await _addImageFilePart(request, spdPath, 'spd_$cprId');

        final response = await http.Response.fromStream(
          await request.send().timeout(const Duration(minutes: 2)),
        );

        if (response.statusCode == 200) {
          await db.update(
            cprtable,
            {colcprtraflag: 'S'},
            where: 'cpr_id = ?',
            whereArgs: [row['cpr_id']],
          );
          DataNotifier.instance.notify();
        } else {
          throw 'Failed to upload CPR $cprId (Status: ${response.statusCode})';
        }
      }

      // --- PHASE 2: SYNC LOT PICTURES (Individual Uploads) ---
      for (int i = 0; i < uploadableLp.length; i++) {
        var row = uploadableLp[i];
        final lpId = (row['id'] ?? '').toString();
        _updateProgress(
          0.50 + (i / uploadableLp.length * 0.20),
          'Uploading Lot Pic $lpId...',
        );

        final request = http.MultipartRequest('POST', uri);
        request.headers[HttpHeaders.authorizationHeader] = globals
            .globalhttpauth
            .toString();
        request.fields['usernameid'] = globals.globalusernameid.toString();

        request.fields['splotpictures'] = jsonEncode([
          {
            'id': row['id'] ?? 0,
            'request_id': row['request_id'] ?? 0,
            'landprep_date': row['lp_traflag'] != 'E'
                ? (row['landprep_date'] ?? '')
                      .toString()
                      .replaceFirst('T', ' ')
                      .split('.')[0]
                : '',
            'actualplanted_date': row['ap_traflag'] != 'E'
                ? (row['actualplanted_date'] ?? '')
                      .toString()
                      .replaceFirst('T', ' ')
                      .split('.')[0]
                : '',
            'ap_traflag': row['ap_traflag'] == 'A' ? 'S' : row['ap_traflag'],
            'lp_traflag': row['lp_traflag'] == 'A' ? 'S' : row['lp_traflag'],
          },
        ]);
        final requestid = (row['request_id'] ?? '').toString();
        final String lp = 'lp_$requestid.jpg';
        final String ap = 'ap_$requestid.jpg';

        final String lpPath = '//storage/emulated/0/DCIM/LOT_PICTURES/$lp';
        final String apPath = '//storage/emulated/0/DCIM/LOT_PICTURES/$ap';

        if (row['lp_traflag'] == 'A') {
          await _addImageFilePart(request, lpPath, 'lp_$requestid');
        }
        if (row['ap_traflag'] == 'A') {
          await _addImageFilePart(request, apPath, 'ap_$requestid');
        }

        final response = await http.Response.fromStream(
          await request.send().timeout(const Duration(minutes: 2)),
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          await db.update(
            lotPicturesTable,
            {collptraflag: 'S', colaptraflag: 'S'},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          DataNotifier.instance.notify();
        } else {
          throw 'Failed to upload Lot Picture $lpId (Status: ${response.statusCode})';
        }
      }

      // --- PHASE 3: MASTER DATA DOWNLOAD ---
      _updateProgress(0.80, 'Downloading updated master data...');

      // Using a POST request without files for Phase 3 to minimize overhead
      final finalReq = await http
          .post(
            uri,
            body: {'usernameid': globals.globalusernameid.toString()},
            headers: {
              HttpHeaders.authorizationHeader: globals.globalhttpauth
                  .toString(),
            },
          )
          .timeout(const Duration(minutes: 1));
      print(finalReq.body);

      if (finalReq.statusCode == 200) {
        final batch = db.batch();
        final Map<String, dynamic> decodedData = jsonDecode(
          finalReq.body,
        ); // Decode once

        _updateProgress(0.85, 'Processing Master Data...');

        // 1. Planters - Passing only the 'planters' section
        if (decodedData.containsKey('planters')) {
          for (var p in decodedData['planters']) {
            batch.insert(
              planterTable,
              Planter(
                int.parse(p['plid']),
                p['plcode'],
                p['plname'],
                p['traflag'],
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // 2. Requests - Passing only the 'sprequest' section
        if (decodedData.containsKey('sprequest')) {
          for (var r in decodedData['sprequest']) {
            batch.insert(
              requestTable,
              Requests(
                int.parse(r['request_id']),
                int.parse(r['request_no']),
                r['request_date'],
                r['pl_code'],
                r['pl_name'],
                r['location'],
                r['area'],
                double.parse(r['qty'].toString()).toInt(),
                double.parse(r['remaining_qty'].toString()).toInt(),
                double.parse(r['delivered_qty'].toString()).toInt(),
                int.parse(r['plid']),
                int.parse(r['forcpr']),
                r['traflag'],
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // 3. Coordinators - Passing only the 'coordinator' section
        if (decodedData.containsKey('coordinator')) {
          for (var c in decodedData['coordinator']) {
            batch.insert(
              frTable,
              Coordinators(
                int.parse(c['fr_id']),
                c['fr_code'],
                c['fr_name'],
                c['traflag'],
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // 4. Varieties - Passing only the 'variety' section
        if (decodedData.containsKey('variety')) {
          for (var v in decodedData['variety']) {
            batch.insert(
              varietytable,
              Variety(
                int.parse(v['id']),
                v['description'],
                v['traflag'],
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // 5. Permissions - Passing only the 'permission' section
        if (decodedData.containsKey('permission')) {
          for (var p in decodedData['permission']) {
            batch.insert(
              userpermissionstable,
              UserPermissions(
                int.parse(p['moduleid']),
                int.parse(p['hasaccess']),
              ).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        await batch.commit(noResult: true);
        DataNotifier.instance.notify();
        _updateProgress(1.0, 'Sync Completed');
        return true;
      } else {
        _updateProgress(
          1.0,
          'Uploads finished, but Master Data refresh failed.',
        );
        return true; // Still return true because uploads worked
      }
    } catch (e) {
      _updateProgress(0, 'Sync Failed: $e');
      return false;
    }
  }

  Future<bool> savesyncupdate(context, conntype) async {
    final db = await DBHelper.db;
    final List<Map<String, dynamic>> cprlist = await db.query(
      cprtable,
      where: '$colcprtraflag = ? OR $colcprtraflag = ?',
      whereArgs: ['A', 'U'],
    );

    final List<Map<String, dynamic>> lpids = await db.query(
      lotPicturesTable,
      columns: [collpid],
    );

    final List<Map<String, dynamic>> lplist = await db.query(
      lotPicturesTable,
      where: '$collptraflag = ? OR $colaptraflag = ?',
      whereArgs: ['A', 'A'],
    );
    try {} catch (e) {
      print("Connection Error: $e");
    }
    print(conntype);
    print(context);
    return await savesync(context, conntype, cprlist, lplist) ?? false;
    // print('')
    // return true;
  }

  Future<bool> checkiffirst(context, conntype) async {
    final planters = await PlanterServices.getPlanters();

    if (planters.isEmpty) {
      print('1st');
      return await savesyncfirst(context, conntype) ?? false;
    } else {
      print('2nd');
      return await savesyncupdate(context, conntype);
    }
  }

  // Future<bool?> delayedAction(context, conntype) async {
  //   checkiffirst(context, conntype);
  //   return true;
  // }

  // String _compressBase64(String b64, {int maxDim = 1024, int quality = 70}) {
  //   if (b64.isEmpty) return b64;
  //   print('>>> _compressBase64 input: ${b64.length} bytes');
  //   try {
  //     final decoded = img.decodeImage(base64Decode(b64));
  //     if (decoded == null) {
  //       print('>>> _compressBase64: decode returned null — returning original');
  //       return b64;
  //     }
  //     print('>>> decoded size: ${decoded.width}x${decoded.height}');
  //     final img.Image resized;
  //     if (decoded.width > maxDim || decoded.height > maxDim) {
  //       final double scale =
  //           maxDim /
  //           (decoded.width > decoded.height ? decoded.width : decoded.height);
  //       final int newW = (decoded.width * scale).round();
  //       final int newH = (decoded.height * scale).round();
  //       resized = img.copyResize(decoded, width: newW, height: newH);
  //     } else {
  //       resized = decoded;
  //     }
  //     print('>>> resized size: ${resized.width}x${resized.height}');
  //     final encoded = img.encodeJpg(resized, quality: quality);
  //     print('>>> encoded raw bytes: ${encoded.length}');
  //     final result = base64Encode(encoded);
  //     print('>>> _compressBase64 output: ${result.length} bytes');
  //     return result;
  //   } catch (e) {
  //     print('>>> _compressBase64 exception: $e — returning original');
  //     return b64;
  //   }
  // }
}
