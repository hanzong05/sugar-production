import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/core/services/lotpicture_service.dart';
import 'package:sugar_production/core/services/data.dart' show LotPicNotifier;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data'; // ← add this

class LandPrepController extends ChangeNotifier {
  final Map<String, dynamic> request;
  final Planter planter;

  LandPrepController({required this.request, required this.planter});

  File? landPrepImage;
  File? plantedAreaImage;
  bool isSubmitting = false;
  bool landPrepLocked = false;
  bool plantedAreaLocked = false;
  bool landPrepSynced = false;
  bool plantedAreaSynced = false;
  String? landPrepDate;
  String? plantedAreaDate;
  // In LandPrepController — add these fields:int
  DateTime? landPrepInputDate;
  DateTime? plantedInputDate;

  void setLandPrepInputDate(DateTime date) {
    landPrepInputDate = date;
    notifyListeners();
  }

  void setPlantedInputDate(DateTime date) {
    plantedInputDate = date;
    notifyListeners();
  }

  // Add this helper in the controller
  String _formatDateForDb(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String get requestId => request['request_id'].toString();

  Future<String> _saveImageFile(
    Uint8List bytes,
    String prefix,
    String id,
  ) async {
    Directory directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/DCIM/LOT_PICTURES');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final String filePath = p.join(directory.path, '${prefix}_$id.jpg');
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  Future<File?> _getSavedImageFile(String prefix, String id) async {
    Directory directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/DCIM/LOT_PICTURES');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final String filePath = p.join(directory.path, '${prefix}_$id.jpg');
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    }

    return null;
  }

  Future<void> loadExistingImages() async {
    Map<String, dynamic>? meta;
    try {
      meta = await LotpictureService.getLotPictureByRequestId(requestId);
    } catch (e) {
      debugPrint('[LP] Error fetching meta: $e');
    }

    if (meta == null) {
      debugPrint('[LP] No existing record found for requestId: $requestId');
      return;
    }

    debugPrint('[LP] Raw meta from DB: $meta');

    final lpTraflag = meta['lp_traflag']?.toString() ?? 'E';
    final apTraflag = meta['ap_traflag']?.toString() ?? 'E';

    landPrepSynced = lpTraflag == 'S';
    plantedAreaSynced = apTraflag == 'S';
    landPrepDate = meta['landprep_date']?.toString();
    plantedAreaDate = meta['actualplanted_date']?.toString();

    if (landPrepDate != null && landPrepDate!.isNotEmpty) {
      try {
        landPrepInputDate = DateTime.parse(landPrepDate!);
      } catch (e) {
        debugPrint('[LP] Failed to parse landPrepDate: $e');
      }
    }

    if (plantedAreaDate != null && plantedAreaDate!.isNotEmpty) {
      try {
        plantedInputDate = DateTime.parse(plantedAreaDate!);
      } catch (e) {
        debugPrint('[LP] Failed to parse plantedAreaDate: $e');
      }
    }

    final lpFile = await _getSavedImageFile('lp', requestId.toString());
    if (lpFile != null) {
      landPrepImage = lpFile;
      landPrepLocked = lpTraflag != 'E';
    }

    final apFile = await _getSavedImageFile('ap', requestId.toString());
    if (apFile != null) {
      plantedAreaImage = apFile;
      plantedAreaLocked = apTraflag != 'E';
    }

    notifyListeners();
  }

  void setLandPrepImage(File img) {
    landPrepImage = img;
    landPrepDate = _formatDateForDb(landPrepInputDate);
    notifyListeners();
  }

  void setPlantedAreaImage(File img) {
    plantedAreaImage = img;
    plantedAreaDate = _formatDateForDb(plantedInputDate);
    notifyListeners();
  }

  /// Returns null on success, error string on failure.
  Future<String?> submit() async {
    isSubmitting = true;
    notifyListeners();

    try {
      Map<String, dynamic>? existing;
      try {
        existing = await LotpictureService.getLotPictureByRequestId(requestId);
      } catch (_) {}

      String lpTraflag = existing?['lp_traflag']?.toString() ?? 'E';
      String apTraflag = existing?['ap_traflag']?.toString() ?? 'E';
      String lpDate = existing?['landprep_date']?.toString() ?? '';
      String apDate = existing?['actualplanted_date']?.toString() ?? '';

      if (landPrepImage != null && !landPrepLocked) {
        await _saveImageFile(
          await landPrepImage!.readAsBytes(),
          'lp',
          requestId.toString(),
        );
        lpTraflag = 'A';
        lpDate = _formatDateForDb(landPrepInputDate);
      }

      if (plantedAreaImage != null && !plantedAreaLocked) {
        await _saveImageFile(
          await plantedAreaImage!.readAsBytes(),
          'ap',
          requestId.toString(),
        );
        apTraflag = 'A';
        apDate = _formatDateForDb(plantedInputDate);
      }

      final map = {
        'request_id': requestId,
        'landprep_date': lpDate,
        'actualplanted_date': apDate,
        'lp_traflag': lpTraflag,
        'ap_traflag': apTraflag,
        'traflag': 'A',
      };

      await LotpictureService.upsertLotPicture(requestId, map);
      LotPicNotifier.instance.notify();
      return null;
    } catch (e) {
      debugPrint('[LP] Submit error: $e');
      return 'Error submitting: $e';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      String pad(int n) => n.toString().padLeft(2, '0');
      const months = [
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
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ${pad(dt.hour)}:${pad(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }
}
