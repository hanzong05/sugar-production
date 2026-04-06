import 'package:flutter/material.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/core/services/cpr_reprint.dart';

class CprInfoController extends ChangeNotifier {
  final CPR cpr;

  String planterName = 'Loading...';
  String lotLocation = 'Loading...';
  String variety = 'Loading...';
  String cutter = 'Loading...';
  String sourceLocation = 'Loading...';
  String requestNumber = 'Loading...';
  String deliveredByName = 'Loading...';
  String coordinatorName = 'Loading...';
  String receivedBy = 'Loading...';
  String haulingPaid = 'Loading...';
  String haulingAmount = 'Loading...';
  String cuttingModeName = 'Loading...';
  String sourcePlanter = 'Loading...';
  String sourcePlanterCode = 'Loading...';

  CprInfoController(this.cpr) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final details = await CprService.getcprDetails(cpr);
      planterName = details['planterName']!;
      requestNumber = details['requestNumber']!;
      lotLocation = details['lotLocation']!;
      variety = details['variety']!;
      cutter = details['cutter']!;
      sourceLocation = details['sourceLocation']!;
      deliveredByName = details['deliveredByName']!;
      coordinatorName = details['coordinator'] ?? 'N/A';
      cuttingModeName = details['cuttingmode'] ?? 'N/A';
      receivedBy = cpr.colcprrecievedby ?? 'N/A';
      sourcePlanter = details['sourceplanter'] ?? 'N/A';
      sourcePlanterCode = details['sourceplanter_code'] ?? 'N/A';
      haulingPaid = cpr.colcprhlngstat == 1
          ? 'Yes'
          : cpr.colcprhlngstat == 2
          ? 'No'
          : 'N/A';
      haulingAmount = (cpr.colcprhlngqty ?? 0).toString();
    } catch (_) {
      planterName = requestNumber = lotLocation = variety = cutter =
          sourceLocation = deliveredByName = coordinatorName = receivedBy =
              'Error';
    }
    notifyListeners();
  }

  Map<String, String> get printDetails => {
    'planterName': planterName,
    'requestNumber': requestNumber,
    'lotLocation': lotLocation,
    'variety': variety,
    'cutter': cutter,
    'sourceLocation': sourceLocation,
    'deliveredByName': deliveredByName,
    'coordinator': coordinatorName,
    'cuttingmode': cuttingModeName,
    'sourceplanter': sourcePlanter,
    'sourceplanter_code': sourcePlanterCode,
  };

  void print() {
    final service = Printcprinforeprint();
    service.printingcount(cpr, 1, cpr.colcprid, printDetails);
  }

  String formatDate(String? s) {
    if (s == null || s.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(s);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return s;
    }
  }

  String formatTime(String? s) {
    if (s == null || s.isEmpty) return '';
    try {
      final dt = DateTime.parse(s);
      final h = dt.hour;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$hour:$min $period';
    } catch (_) {
      return '';
    }
  }
}
