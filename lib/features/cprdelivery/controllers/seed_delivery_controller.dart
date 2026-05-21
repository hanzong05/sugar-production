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
import 'package:sugar_production/core/services/lotcode_service.dart';
import 'package:sugar_production/core/services/data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SeedDeliveryController extends ChangeNotifier {
  final Map<String, dynamic> request;
  final Planter planter;

  SeedDeliveryController({required this.request, required this.planter}) {
    selectedDate = DateTime.now();
    _loadDropdowns();
  }

  // ── Text Controllers ────────────────────────────────────────────
  final qtyController = TextEditingController();
  final hlngqtyController = TextEditingController();
  final cuttingqtyController = TextEditingController();
  final sacksqtyController = TextEditingController();
  final othersqtyController = TextEditingController();
  final receivedByController = TextEditingController();

  String? signaturePath;
  String? imagePath;
  String? seedImagePath;
  CPR? savedCpr;

  // ── Dates ───────────────────────────────────────────────────────
  late DateTime selectedDate;
  DateTime? cuttingDate;

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
  List<Map<String, dynamic>> lotCodes = [];

  // ── Selected IDs ────────────────────────────────────────────────
  int? selectedVarietyId;
  int? selectedCutterId;
  int? selectedLocationId;
  int? selectedSourcePlanterId;
  int? selectedCoordinatorId;
  int? selectedCuttingmodeId;
  int? selectedLotCodeId;

  // ── Selected Labels ─────────────────────────────────────────────
  String selectedVarietyLabel = '';
  String selectedCutterLabel = '';
  String selectedLocationLabel = '';
  String selectedSourcePlanterLabel = '';
  String selectedCoordinatorLabel = '';
  String selectedCuttingmodeLabel = '';
  String selectedSourcePlanterCode = '';
  String? selectedLotCodeLabel;

  // ── Status flags ────────────────────────────────────────────────
  int haulingStatus = 0;
  int cuttingStatus = 0;
  int sacksStatus = 0;
  int othersStatus = 0;

  int get neededQty {
    final requested = int.tryParse('${request['total_qty'] ?? 0}') ?? 0;
    final delivered = int.tryParse('${request['delivered_qty'] ?? 0}') ?? 0;
    return requested - delivered;
  }

  Future<String> _saveImageFile(
    Uint8List bytes,
    String prefix,
    String id,
  ) async {
    Directory directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/DCIM/CPR_IMAGES');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath = p.join(directory.path, '${prefix}_$id.jpg');
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
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

      varieties = List<Map<String, dynamic>>.from(results[0]);
      cutters = List<Map<String, dynamic>>.from(results[1]);
      locations = List<Map<String, dynamic>>.from(results[2]);
      sourceplanters = List<Map<String, dynamic>>.from(results[3]);
      coordinators = List<Map<String, dynamic>>.from(results[4]);
      cuttingmodes = List<Map<String, dynamic>>.from(results[5]);
    } catch (e) {
      debugPrint('Error loading dropdowns: $e');
    } finally {
      isLoadingDropdowns = false;
      notifyListeners();
    }
  }

  // ── Load Lot Codes by Source Planter ────────────────────────────
  Future<void> _loadLotCodes(int sourcePlanterId) async {
    try {
      lotCodes = await LotcodeService.getLotCodesBySourcePlanter(
        sourcePlanterId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading lot codes: $e');
    }
  }

  // ── Setters ─────────────────────────────────────────────────────
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

  void setCuttingStatus(int value) {
    cuttingStatus = cuttingStatus == value ? 0 : value;
    if (cuttingStatus != 1) cuttingqtyController.clear();
    notifyListeners();
  }

  void setOthersStatus(int value) {
    othersStatus = othersStatus == value ? 0 : value;
    if (othersStatus != 1) othersqtyController.clear();
    notifyListeners();
  }

  void setSacksStatus(int value) {
    sacksStatus = sacksStatus == value ? 0 : value;
    if (sacksStatus != 1) sacksqtyController.clear();
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
    // Reset lot code whenever source planter changes
    selectedLotCodeId = null;
    selectedLotCodeLabel = null;
    lotCodes = [];
    notifyListeners();

    if (id != null) _loadLotCodes(id);
  }

  void setLotCode(int? id, String label) {
    selectedLotCodeId = id;
    selectedLotCodeLabel = label;
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
  Future<String?> submit() async {
    final user = AuthService().currentUser;

    if (qtyController.text.trim().isEmpty) {
      return 'Quantity is required';
    }

    final int qty = int.tryParse(qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      return 'Invalid quantity';
    }

    if (qty > neededQty) {
      return 'Quantity exceeds needed amount ($neededQty)';
    }

    if (selectedLocationId == null) return 'Please select source location';
    if (selectedVarietyId == null) return 'Please select variety';
    if (selectedCutterId == null) return 'Please select cutter';
    if (selectedSourcePlanterId == null) return 'Please select source planter';
    if (selectedCoordinatorId == null) return 'Please select coordinator';
    if (selectedCuttingmodeId == null) return 'Please select cutting mode';
    if (selectedLotCodeId == null) return 'Please select lot code';
    if (receivedByController.text.trim().isEmpty) {
      return 'Please enter received by';
    }
    if (signatureBytes == null) return 'Signature is required';
    if (proofImage == null) return 'Proof image is required';
    if (proofSeedImage == null) return 'Seed image is required';

    final int hlngqty = int.tryParse(hlngqtyController.text.trim()) ?? 0;
    final int cuttingqty = int.tryParse(cuttingqtyController.text.trim()) ?? 0;
    final int sacksqty = int.tryParse(sacksqtyController.text.trim()) ?? 0;
    final int othersqty = int.tryParse(othersqtyController.text.trim()) ?? 0;

    isSubmitting = true;
    notifyListeners();

    try {
      final int currentUserName = user?.usernameid ?? 0;
      final String currentUserId = user?.username ?? 'N/A';

      final cprCode = await CprService.generatecprCode(currentUserId);
      final String deliveryDate = selectedDate.toIso8601String();
      final String cprRef = cprCode['refno'].toString();

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
        'cutting_paid': cuttingStatus,
        'cutting_amount': cuttingqty,
        'sacks_paid': sacksStatus,
        'sacks_amount': sacksqty,
        'others_paid': othersStatus,
        'others_amount': othersqty,
        'lot_code': selectedLotCodeLabel ?? '',
        'traflag': 'A',
      };

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
    cuttingqtyController.clear();
    sacksqtyController.clear();
    othersqtyController.clear();
    receivedByController.clear();

    selectedDate = DateTime.now();
    cuttingDate = null;

    signatureBytes = null;
    proofImage = null;
    proofSeedImage = null;

    signaturePath = null;
    imagePath = null;
    seedImagePath = null;
    savedCpr = null;

    selectedVarietyId = null;
    selectedCutterId = null;
    selectedLocationId = null;
    selectedSourcePlanterId = null;
    selectedCoordinatorId = null;
    selectedCuttingmodeId = null;
    selectedLotCodeId = null;

    selectedVarietyLabel = '';
    selectedCutterLabel = '';
    selectedLocationLabel = '';
    selectedSourcePlanterLabel = '';
    selectedCoordinatorLabel = '';
    selectedCuttingmodeLabel = '';
    selectedSourcePlanterCode = '';
    selectedLotCodeLabel = null;

    lotCodes = [];

    haulingStatus = 0;
    cuttingStatus = 0;
    sacksStatus = 0;
    othersStatus = 0;

    notifyListeners();
  }

  @override
  void dispose() {
    qtyController.dispose();
    hlngqtyController.dispose();
    cuttingqtyController.dispose();
    sacksqtyController.dispose();
    othersqtyController.dispose();
    receivedByController.dispose();
    super.dispose();
  }
}
