import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/services/cpr_print_service.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'package:sugar_production/core/services/coords_service.dart';
import 'package:sugar_production/core/services/variety_service.dart';
import 'package:sugar_production/core/services/cutter_service.dart';
import 'package:sugar_production/core/services/location_service.dart';
import 'package:sugar_production/core/services/src_planter_service.dart';
import 'package:sugar_production/core/services/cutting_service.dart';
import 'package:sugar_production/core/services/data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class SeedDeliveryController extends ChangeNotifier {
  final Map<String, dynamic> request;
  final Planter planter;

  SeedDeliveryController({required this.request, required this.planter}) {
    _selectedDate = DateTime.now();
    _loadDropdowns();
  }

  // ── Text Controllers ────────────────────────────────────────────
  final qtyController = TextEditingController();
  final hlngqtyController = TextEditingController();
  final receivedByController = TextEditingController();
  String? signaturePath;
  String? imagePath;
  String? seedImagePath;
  CPR? savedCpr;
  // ── Dates ───────────────────────────────────────────────────────
  late DateTime selectedDate;
  DateTime? cuttingDate;

  DateTime get _selectedDate => selectedDate;
  set _selectedDate(DateTime v) => selectedDate = v;

  // ── Media ───────────────────────────────────────────────────────
  Uint8List? signatureBytes;
  File? proofImage;
  File? proofSeedImage;

  // ── State ───────────────────────────────────────────────────────
  bool isSubmitting = false;
  bool isLoadingDropdowns = true;

  // ── Dropdown data ───────────────────────────────────────────────
  List<Map<String, dynamic>> varieties = [];
  List<Map<String, dynamic>> cutters = [];
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> sourceplanters = [];
  List<Map<String, dynamic>> coordinators = [];
  List<Map<String, dynamic>> cuttingmodes = [];

  // ── Selected IDs ────────────────────────────────────────────────
  int? selectedVarietyId;
  int? selectedCutterId;
  int? selectedLocationId;
  int? selectedSourcePlanterId;
  int? selectedCoordinatorId;
  int? selectedCuttingmodeId;

  // ── Selected Labels ─────────────────────────────────────────────
  String selectedVarietyLabel = '';
  String selectedCutterLabel = '';
  String selectedLocationLabel = '';
  String selectedSourcePlanterLabel = '';
  String selectedCoordinatorLabel = '';
  String selectedCuttingmodeLabel = '';
  String selectedSourcePlanterCode = '';

  // ── Hauling: 0 = not set, 1 = Yes, 2 = No ──────────────────────
  int haulingStatus = 0;

  int get neededQty {
    final requested = request['total_qty'] ?? 0;
    final delivered = request['delivered_qty'] ?? 0;
    return requested - delivered;
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;

      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }

    return false;
  }

  // Future<void> _saveFileToGallery(
  //   Uint8List bytes,
  //   String prefix,
  //   String id,
  // ) async {
  //   final hasPermission = await _requestGalleryPermission();
  //   if (!hasPermission) {
  //     throw Exception('Gallery permission denied');
  //   }
  //   final dir = await getApplicationDocumentsDirectory();
  //   final path = p.join(dir.path, 'cpr_images', '${prefix}_$id.jpg');
  //   await Directory(p.dirname(path)).create(recursive: true);
  //   await File(path).writeAsBytes(bytes);

  //   final result = await ImageGallerySaverPlus.saveFile(path);
  //   // debugPrint('Saved to gallery: $result');
  // }

  Future<String> _saveImageFile(
    Uint8List bytes,
    String prefix,
    String id,
  ) async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('//storage/emulated/0/DCIM/CPR_IMAGES');
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
    // final dir = await getApplicationDocumentsDirectory();
    // final path = p.join(dir.path, 'cpr_images', '${prefix}_$id.jpg');
    // await Directory(p.dirname(path)).create(recursive: true);
    // await File(path).writeAsBytes(bytes);
    // return path;
    // print(dir.path);
  }

  // ── Load Dropdowns ──────────────────────────────────────────────
  Future<void> _loadDropdowns() async {
    try {
      final results = await Future.wait([
        VarietyService.getAllVariety(),
        CutterService.getAllCutters(),
        LocationService.getAllLocations(),
        SourcePlanterService.getAllSourcePl(),
        CoordsService.getAllCoords(),
        CuttingService.getAllCm(),
      ]);
      varieties = results[0];
      cutters = results[1];
      locations = results[2];
      sourceplanters = results[3];
      coordinators = results[4];
      cuttingmodes = results[5];
    } catch (e) {
      debugPrint('Error loading dropdowns: $e');
      rethrow;
    } finally {
      isLoadingDropdowns = false;
      notifyListeners();
    }
  }

  // ── Setters (notify after each) ─────────────────────────────────
  void setDate(DateTime d) {
    selectedDate = d;
    notifyListeners();
  }

  void setCuttingDate(DateTime d) {
    cuttingDate = d;
    notifyListeners();
  }

  void setSignature(Uint8List bytes) {
    signatureBytes = bytes;
    notifyListeners();
  }

  void setProofImage(File f) {
    proofImage = f;
    notifyListeners();
  }

  void setProofSeedImage(File f) {
    proofSeedImage = f;
    notifyListeners();
  }

  void setHaulingStatus(int value) {
    haulingStatus = haulingStatus == value ? 0 : value;
    if (haulingStatus != 1) hlngqtyController.clear();
    notifyListeners();
  }

  void setVariety(int? id, String label) {
    selectedVarietyId = id;
    selectedVarietyLabel = label;
    notifyListeners();
  }

  void setCutter(int? id, String label) {
    selectedCutterId = id;
    selectedCutterLabel = label;
    notifyListeners();
  }

  void setLocation(int? id, String label) {
    selectedLocationId = id;
    selectedLocationLabel = label;
    notifyListeners();
  }

  void setSourcePlanter(int? id, String label, [String? code]) {
    selectedSourcePlanterId = id;
    selectedSourcePlanterLabel = label;
    selectedSourcePlanterCode = code ?? '';
    notifyListeners();
  }

  void setCoordinator(int? id, String label) {
    selectedCoordinatorId = id;
    selectedCoordinatorLabel = label;
    notifyListeners();
  }

  void setCuttingMode(int? id, String label) {
    selectedCuttingmodeId = id;
    selectedCuttingmodeLabel = label;
    notifyListeners();
  }

  // ── Submit ──────────────────────────────────────────────────────
  /// Returns null on success, or an error string on failure.
  Future<String?> submit() async {
    final user = AuthService().currentUser;
    final int qty = int.parse(qtyController.text);

    if (qty > neededQty) return 'Quantity exceeds needed amount ($neededQty)';

    final int hlngqty = int.tryParse(hlngqtyController.text) ?? 0;
    isSubmitting = true;
    notifyListeners();

    try {
      final int currentUserName = user?.usernameid ?? 0;
      final String currentUserId = user?.username ?? 'N/A';
      final cprCode = await CprService.generatecprCode(currentUserId);
      final String deliveryDate = selectedDate.toIso8601String();
      final String cprRef = cprCode['refno'].toString();

      // ── Save images as files, store paths ──────────────────────
      signaturePath = await _saveImageFile(signatureBytes!, 'sig', cprRef);

      imagePath = await _saveImageFile(
        await proofImage!.readAsBytes(),
        'pic',
        cprRef,
      );

      seedImagePath = await _saveImageFile(
        await proofSeedImage!.readAsBytes(),
        'spd',
        cprRef,
      );

      final Map<String, dynamic> cprData = {
        'cpr_refno': cprCode['refno'],
        'planter_id': planter.plid,
        'request_id': int.parse(request['request_id'].toString()),
        'qty': qty,
        'location_id': selectedLocationId,
        'variety_id': selectedVarietyId,
        'delivery_date': deliveryDate,
        'cutter_id': selectedCutterId,
        'print_count': 0,
        'delivered_by_id': currentUserName,
        'series': cprCode['series'],
        'source_planter': selectedSourcePlanterId,
        'rcvfr_id': selectedCoordinatorId,
        'recieved_by': receivedByController.text.trim(),
        'cuttingmode': selectedCuttingmodeId,
        'cuttingdate': cuttingDate?.toIso8601String() ?? '',
        'hauling_paid': haulingStatus,
        'hauling_amount': hlngqty,
        'traflag': 'A',
      };
      print('CPR CODE ${cprCode['series']}');
      final int requestId = int.parse(request['request_id'].toString());
      final int cprId = await CprService.submitDelivery(
        cprData: cprData,
        requestId: requestId,
        qty: qty,
      );

      savedCpr = await CprService.getcprsById(cprId);
      final Map<String, String> fetchedDetails = savedCpr != null
          ? await CprService.getcprDetails(savedCpr!)
          : {};

      final Map<String, String> details = {
        'planterName': planter.plname ?? 'N/A',
        'requestNumber': request['request_no']?.toString() ?? 'N/A',
        'lotLocation': request['lot_location']?.toString() ?? 'N/A',
        'variety': selectedVarietyLabel.isNotEmpty
            ? selectedVarietyLabel
            : 'N/A',
        'sourceplanter': selectedSourcePlanterLabel.isNotEmpty
            ? selectedSourcePlanterLabel
            : 'N/A',
        'cutter': selectedCutterLabel.isNotEmpty ? selectedCutterLabel : 'N/A',
        'sourceLocation': selectedLocationLabel.isNotEmpty
            ? selectedLocationLabel
            : 'N/A',
        'deliveredByName': fetchedDetails['deliveredByName'] ?? 'N/A',
        'coordinator': selectedCoordinatorLabel.isNotEmpty
            ? selectedCoordinatorLabel
            : 'N/A',
        'cuttingmode': selectedCuttingmodeLabel.isNotEmpty
            ? selectedCuttingmodeLabel
            : 'N/A',
        'sourceplanter_code': selectedSourcePlanterCode.isNotEmpty
            ? selectedSourcePlanterCode
            : 'N/A',
      };

      if (savedCpr != null) {
        final printService = Printcprinfoprint();
        printService.printingcount(savedCpr!, 1, savedCpr!.colcprid, details);
      }

      DataNotifier.instance.notify();
      reset();
      return null;
    } catch (e) {
      return 'Error saving CPR: $e';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Reset ───────────────────────────────────────────────────────
  void reset() {
    qtyController.clear();
    hlngqtyController.clear();
    receivedByController.clear();
    selectedDate = DateTime.now();
    cuttingDate = null;
    signatureBytes = null;
    proofImage = null;
    proofSeedImage = null;
    selectedVarietyId = null;
    selectedCutterId = null;
    selectedLocationId = null;
    selectedSourcePlanterId = null;
    selectedCoordinatorId = null;
    selectedCuttingmodeId = null;
    selectedVarietyLabel = '';
    selectedCutterLabel = '';
    selectedLocationLabel = '';
    selectedSourcePlanterLabel = '';
    selectedCoordinatorLabel = '';
    selectedCuttingmodeLabel = '';
    selectedSourcePlanterCode = '';
    haulingStatus = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    qtyController.dispose();
    hlngqtyController.dispose();
    receivedByController.dispose();
    super.dispose();
  }
}
