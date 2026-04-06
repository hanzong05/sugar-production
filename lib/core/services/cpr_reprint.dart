import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sunmi_printer_plus/column_maker.dart';

class Printcprinforeprint {
  void printingcount(
    CPR cprinfo,
    int count,
    int cprid,
    Map<String, String> details,
  ) async {
    for (int i = 0; i < count; i++) {
      await CprService.incrementPrintCount(cprid);
      // await CprService.incrementSeries(cprid);
      final updatedcpr = await CprService.getcprsById(cprid);
      final updatedCounter = updatedcpr?.colcprcounter ?? 0;
      await _printinfo(cprinfo, cprid, updatedCounter, details);
      if ((i + 1) != count) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    await SunmiPrinter.exitTransactionPrint(true);
  }

  // ─── Helper: single print line with SM bold left style ───────────────────
  Future<void> _printLine(String text) async {
    const int maxChars = 30; // same as column width

    String truncated = text.length > maxChars
        ? text.substring(0, maxChars) // cut extra characters
        : text;

    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: truncated,
          width: maxChars,
          align: SunmiPrintAlign.LEFT,
        ),
      ],
    );
  }

  // ─── Date formatters ─────────────────────────────────────────────────────
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateString);
      return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateString);
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$hour:$m $period';
    } catch (_) {
      return '';
    }
  }

  // ─── Main print method ───────────────────────────────────────────────────
  Future<void> _printinfo(
    CPR cprinfo,
    int cprid,
    int counter,
    Map<String, String> details,
  ) async {
    final DateTime now = DateTime.now();
    final String formattedPrintDate =
        '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final String refno = cprinfo.colccprrefno;
    final String planterName = details['planterName'] ?? 'N/A';
    final String requestNumber = details['requestNumber'] ?? 'N/A';
    final String lotLocation = details['lotLocation'] ?? 'N/A';
    final String variety = details['variety'] ?? 'N/A';
    final String cutter = details['cutter'] ?? 'N/A';
    final String sourceLocation = details['sourceLocation'] ?? 'N/A';
    final String coordinator = details['coordinator'] ?? 'N/A';
    final String cuttingmode = details['cuttingmode'] ?? 'N/A';
    final String deliveredBy = details['deliveredByName'] ?? 'N/A';
    final String sourceplanter = details['sourceplanter'] ?? 'N/A';
    final String sourceplantercode = details['sourceplanter_code'] ?? 'N/A';
    final String hauling = cprinfo.colcprhlngstat == 1
        ? 'Yes'
        : cprinfo.colcprhlngstat == 2
        ? 'No'
        : 'N/A';

    await _bindingPrinter();
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);

    await SunmiPrinter.printText(
      'Scan Me',
      style: SunmiStyle(
        fontSize: SunmiFontSize.SM,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printQRCode(refno, size: 4);
    await SunmiPrinter.printText(
      'CPR-$refno',
      style: SunmiStyle(
        fontSize: SunmiFontSize.MD,
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await SunmiPrinter.line();

    await _printLine('Ref #: CPR-$refno');
    await _printLine(
      'Delivery Date:${_formatDate(cprinfo.colcprdatedelivered)}:${_formatTime(cprinfo.colcprdatedelivered)}',
    );
    await _printLine('Request #:$requestNumber');
    await _printLine('Planter:$planterName');
    await _printLine('Location:$lotLocation');
    await _printLine('Qty Pcs:${cprinfo.colcprqty}');
    await _printLine('Qty Bags:${((cprinfo.colcprqty ?? 0) / 200).round()}');
    await _printLine('Source Planter:$sourceplanter');
    await _printLine('Source Pl-code:$sourceplantercode');
    await _printLine('Source Loc:$sourceLocation');
    await _printLine('Source Variety:$variety');
    await _printLine('Cutter:$cutter');
    await _printLine('Cutting Mode:$cuttingmode');
    await _printLine('Cutting Date:${_formatDate(cprinfo.colcprcmdate)}');
    await _printLine('Hauling Paid:$hauling');
    await _printLine('Hauling Amount:${cprinfo.colcprhlngqty ?? 'N/A'}');
    await _printLine('Received By:${cprinfo.colcprrecievedby ?? 'N/A'}');
    await _printLine('Recieve CC:$coordinator');
    await _printLine('Source CC:$deliveredBy'); // username

    // ── Cutting ────────────────────────────────────────────────────────────

    // ── Footer ─────────────────────────────────────────────────────────────
    // await _printLine('RePrint Count: $counter');
    await _printLine(
      'Printed Date:${_formatDate(cprinfo.colcprdatedelivered)}:${_formatTime(cprinfo.colcprdatedelivered)}',
    );
    await _printLine('RePrinted Date:$formattedPrintDate');

    // ── Footer QR ──────────────────────────────────────────────────────────
    await SunmiPrinter.line();
    await SunmiPrinter.printText(
      'CPR-$refno',
      style: SunmiStyle(
        fontSize: SunmiFontSize.MD,
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printQRCode(refno, size: 4);
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.submitTransactionPrint();
    await SunmiPrinter.exitTransactionPrint(true);
  }

  Future<bool?> _bindingPrinter() async {
    return await SunmiPrinter.bindingPrinter();
  }
}
