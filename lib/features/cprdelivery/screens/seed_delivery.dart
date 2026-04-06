import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/features/signature/screens/signature.dart';
import 'package:sugar_production/features/camera/screens/camera_capture.dart';
import '../controllers/seed_delivery_controller.dart';
import '../widgets/search_picker.dart';
import '../widgets/form_field.dart';
import '../widgets/verification_card.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'package:sugar_production/features/cprhistory/screens/cpr_info.dart';

class SeedDeliveryForm extends StatefulWidget {
  final Map<String, dynamic> request;
  final Planter planter;
  final VoidCallback? onSubmitSuccess;

  const SeedDeliveryForm({
    super.key,
    required this.request,
    required this.planter,
    this.onSubmitSuccess,
  });

  @override
  State<SeedDeliveryForm> createState() => _SeedDeliveryFormState();
}

class _SeedDeliveryFormState extends State<SeedDeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  late final SeedDeliveryController _ctrl;
  final _scrollController = ScrollController();

  // ── Keys for each field so we can scroll to them ──────────────
  final _qtyKey = GlobalKey();
  final _deliveryDateKey = GlobalKey();
  final _receivedByKey = GlobalKey();
  final _sourcePlanterKey = GlobalKey();
  final _sourceLocationKey = GlobalKey();
  final _varietyKey = GlobalKey();
  final _cutterKey = GlobalKey();
  final _coordinatorKey = GlobalKey();
  final _haulingAmountKey = GlobalKey();
  final _cuttingModeKey = GlobalKey();
  final _cuttingDateKey = GlobalKey();
  final _signatureKey = GlobalKey();
  final _deliveryProofKey = GlobalKey();
  final _seedProofKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ctrl = SeedDeliveryController(
      request: widget.request,
      planter: widget.planter,
    );
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ──────────────────────────────────────────

  Future<void> _openSignatureScreen() async {
    final sig = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => SignatureScreen(
          title: 'Planter Signature',
          signerName: widget.planter.plname ?? 'Planter',
        ),
      ),
    );
    if (sig != null) _ctrl.setSignature(sig);
  }

  Future<void> _captureProof() async {
    final img = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCaptureScreen(
          title: 'Delivery Proof',
          description: 'Take a photo of the seed delivery',
        ),
      ),
    );
    if (img != null) _ctrl.setProofImage(img);
  }

  Future<void> _captureSeedProof() async {
    final img = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCaptureScreen(
          title: 'Seed Piece Proof',
          description: 'Take a photo of the seed Pieces',
        ),
      ),
    );
    if (img != null) _ctrl.setProofSeedImage(img);
  }

  // ── Date pickers ────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: context.appColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _ctrl.setDate(picked);
  }

  Future<void> _pickCuttingDate() async {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: _ctrl.cuttingDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: context.appColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _ctrl.setCuttingDate(picked);
  }

  // ── Preview dialogs ─────────────────────────────────────────────

  void _previewSignature() {
    PreviewDialog.show(
      context,
      title: 'Signature Preview',
      icon: Icons.draw_rounded,
      child: Image.memory(
        _ctrl.signatureBytes!,
        fit: BoxFit.fill,
        width: double.infinity,
      ),
      onRedo: () {
        Navigator.pop(context);
        _openSignatureScreen();
      },
    );
  }

  void _previewProofImage() {
    PreviewDialog.show(
      context,
      title: 'Delivery Proof',
      icon: Icons.camera_alt_rounded,
      tall: true,
      child: Image.file(
        _ctrl.proofImage!,
        fit: BoxFit.contain,
        width: double.infinity,
      ),
      onRedo: () {
        Navigator.pop(context);
        _captureProof();
      },
      redoLabel: 'Retake',
      redoIcon: Icons.camera_alt_rounded,
    );
  }

  void _previewSeedProofImage() {
    PreviewDialog.show(
      context,
      title: 'Seed Pieces Proof',
      icon: Icons.camera_alt_rounded,
      tall: true,
      child: Image.file(
        _ctrl.proofSeedImage!,
        fit: BoxFit.contain,
        width: double.infinity,
      ),
      onRedo: () {
        Navigator.pop(context);
        _captureSeedProof();
      },
      redoLabel: 'Retake',
      redoIcon: Icons.camera_alt_rounded,
    );
  }

  // ── Validation ──────────────────────────────────────────────────

  /// Returns list of {label, key} for every unfilled required field.
  List<Map<String, dynamic>> _getUnfilledFields() {
    final unfilled = <Map<String, dynamic>>[];

    if (_ctrl.qtyController.text.trim().isEmpty ||
        int.tryParse(_ctrl.qtyController.text.trim()) == null ||
        int.parse(_ctrl.qtyController.text.trim()) <= 0) {
      unfilled.add({'label': 'Quantity', 'key': _qtyKey});
    }
    if (_ctrl.receivedByController.text.trim().isEmpty) {
      unfilled.add({'label': 'Received By', 'key': _receivedByKey});
    }
    if (_ctrl.selectedSourcePlanterId == null) {
      unfilled.add({'label': 'Source Planter', 'key': _sourcePlanterKey});
    }
    if (_ctrl.selectedLocationId == null) {
      unfilled.add({'label': 'Source Location', 'key': _sourceLocationKey});
    }
    if (_ctrl.selectedVarietyId == null) {
      unfilled.add({'label': 'Variety', 'key': _varietyKey});
    }
    if (_ctrl.selectedCutterId == null) {
      unfilled.add({'label': 'Cutter', 'key': _cutterKey});
    }
    if (_ctrl.selectedCoordinatorId == null) {
      unfilled.add({'label': 'Coordinator (CC)', 'key': _coordinatorKey});
    }
    if (_ctrl.hlngqtyController.text.trim().isEmpty ||
        int.tryParse(_ctrl.hlngqtyController.text.trim()) == null ||
        int.parse(_ctrl.hlngqtyController.text.trim()) <= 0) {
      unfilled.add({'label': 'Hauling Amount', 'key': _haulingAmountKey});
    }
    if (_ctrl.selectedCuttingmodeId == null) {
      unfilled.add({'label': 'Cutting Mode', 'key': _cuttingModeKey});
    }
    if (_ctrl.cuttingDate == null) {
      unfilled.add({'label': 'Cutting Date', 'key': _cuttingDateKey});
    }
    if (_ctrl.signatureBytes == null) {
      unfilled.add({'label': 'Signature', 'key': _signatureKey});
    }
    if (_ctrl.proofImage == null) {
      unfilled.add({'label': 'Delivery Proof Photo', 'key': _deliveryProofKey});
    }
    if (_ctrl.proofSeedImage == null) {
      unfilled.add({'label': 'Seed Pieces Proof Photo', 'key': _seedProofKey});
    }

    return unfilled;
  }

  /// Scrolls to the widget with the given GlobalKey.
  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1, // show near top
    );
  }

  /// Shows the validation error popup, then scrolls to first unfilled on close.
  void _showValidationDialog(List<Map<String, dynamic>> unfilled) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = context.appColors;
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.accentRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Required Fields',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please fill in the following required fields:',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...unfilled.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        f['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Auto-scroll to the first unfilled field
                Future.delayed(const Duration(milliseconds: 200), () {
                  _scrollToKey(unfilled.first['key'] as GlobalKey);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Go to First',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Submit ──────────────────────────────────────────────────────

  Future<void> _submit() async {
    _formKey.currentState!.validate();

    final unfilled = _getUnfilledFields();
    if (unfilled.isNotEmpty) {
      _showValidationDialog(unfilled);
      return;
    }

    final error = await _ctrl.submit();
    if (!mounted) return;

    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    _showSnackBar('CPR created successfully!', isError: false);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) =>
    //         CprInfo(cpr: _ctrl.savedCpr!, deliveryController: _ctrl),
    //   ),
    // );

    widget.onSubmitSuccess?.call();
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.accentRed : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ── Picker helper ───────────────────────────────────────────────

  void _openPicker({
    required String title,
    required List<Map<String, dynamic>> items,
    required int? selectedId,
    required int Function(Map<String, dynamic>) getId,
    required String Function(Map<String, dynamic>) getLabel,
    required List<String> searchKeys,
    required void Function(int? id, String label, [String? code]) onSelected,
  }) {
    SearchPickerScreen.show(
      context,
      title: title,
      items: items,
      selectedId: selectedId,
      getId: getId,
      getLabel: getLabel,
      searchKeys: searchKeys,
      onSelected: onSelected,
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final colors = context.appColors;
    final d = _ctrl.selectedDate;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final cd = _ctrl.cuttingDate;
    final cuttingDateStr = cd != null
        ? '${cd.year}-${cd.month.toString().padLeft(2, '0')}-${cd.day.toString().padLeft(2, '0')}'
        : 'Not selected';

    return Scaffold(
      backgroundColor: colors.background,
      body: _ctrl.isLoadingDropdowns
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5,
              ),
            )
          : Stack(
              children: [
                Container(height: 30, color: AppTheme.primary),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Delivery Info ──────────────
                                  const FormSectionHeader(
                                    icon: Icons.local_shipping_rounded,
                                    label: 'Delivery Information',
                                  ),
                                  const SizedBox(height: 12),
                                  FormCard(
                                    children: [
                                      CardTextField(
                                        key: _qtyKey,
                                        controller: _ctrl.qtyController,
                                        label: 'Quantity',
                                        icon: Icons.numbers_rounded,
                                        keyboardType: TextInputType.number,
                                        enabled: !_ctrl.isSubmitting,
                                        isFirst: true,
                                        isRequired: true,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'Required';
                                          }
                                          if (int.tryParse(v) == null ||
                                              int.parse(v) <= 0) {
                                            return 'Enter a valid quantity';
                                          }
                                          return null;
                                        },
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardDateField(
                                        key: _deliveryDateKey,
                                        label: 'Delivery Date',
                                        icon: Icons.calendar_today_rounded,
                                        displayValue: dateStr,
                                        onTap: _pickDate,
                                        isRequired: true,
                                        isComplete: true,
                                        enabled: !_ctrl.isSubmitting,
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardTextField(
                                        key: _receivedByKey,
                                        controller: _ctrl.receivedByController,
                                        label: 'Received By',
                                        icon: Icons.person_outline_rounded,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        enabled: !_ctrl.isSubmitting,
                                        isLast: true,
                                        isRequired: true,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Source Details ─────────────
                                  const FormSectionHeader(
                                    icon: Icons.agriculture_rounded,
                                    label: 'Source Details',
                                  ),
                                  const SizedBox(height: 12),
                                  FormCard(
                                    children: [
                                      CardPickerField(
                                        key: _sourcePlanterKey,
                                        label: 'Source Planter',
                                        icon: Icons.person_pin_rounded,
                                        value: _ctrl.selectedSourcePlanterLabel,
                                        isFirst: true,
                                        isRequired: true,
                                        enabled: !_ctrl.isSubmitting,
                                        onTap: () => _openPicker(
                                          title: 'Select Source Planter',
                                          items: _ctrl.sourceplanters,
                                          selectedId:
                                              _ctrl.selectedSourcePlanterId,
                                          getId: (sp) => sp['plsrc_id'] as int,
                                          getLabel: (sp) =>
                                              '${sp['plsrc_name']}',
                                          searchKeys: const [
                                            'plsrc_code',
                                            'plsrc_name',
                                          ],
                                          onSelected: (id, label, [code]) =>
                                              _ctrl.setSourcePlanter(
                                                id,
                                                label,
                                                code,
                                              ),
                                        ),
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardPickerField(
                                        key: _sourceLocationKey,
                                        label: 'Source Location',
                                        icon: Icons.location_on_rounded,
                                        isRequired: true,
                                        value: _ctrl.selectedLocationLabel,
                                        enabled: !_ctrl.isSubmitting,
                                        onTap: () => _openPicker(
                                          title: 'Select Source Location',
                                          items: _ctrl.locations,
                                          selectedId: _ctrl.selectedLocationId,
                                          getId: (l) => l['id'] as int,
                                          getLabel: (l) => '${l['location']}',
                                          searchKeys: const ['location'],
                                          onSelected: (id, label, [code]) =>
                                              _ctrl.setLocation(id, label),
                                        ),
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardPickerField(
                                        key: _varietyKey,
                                        label: 'Variety',
                                        icon: Icons.eco_rounded,
                                        isRequired: true,
                                        value: _ctrl.selectedVarietyLabel,
                                        enabled: !_ctrl.isSubmitting,
                                        onTap: () => _openPicker(
                                          title: 'Select Variety',
                                          items: _ctrl.varieties,
                                          selectedId: _ctrl.selectedVarietyId,
                                          getId: (v) => v['id'] as int,
                                          getLabel: (v) =>
                                              '${v['description']}',
                                          searchKeys: const ['description'],
                                          onSelected: (id, label, [code]) =>
                                              _ctrl.setVariety(id, label),
                                        ),
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardPickerField(
                                        key: _cutterKey,
                                        label: 'Cutter',
                                        icon: Icons.content_cut_rounded,
                                        isRequired: true,
                                        value: _ctrl.selectedCutterLabel,
                                        enabled: !_ctrl.isSubmitting,
                                        onTap: () => _openPicker(
                                          title: 'Select Cutter',
                                          items: _ctrl.cutters,
                                          selectedId: _ctrl.selectedCutterId,
                                          getId: (c) => c['id'] as int,
                                          getLabel: (c) =>
                                              '${c['description']}',
                                          searchKeys: const ['description'],
                                          onSelected: (id, label, [code]) =>
                                              _ctrl.setCutter(id, label),
                                        ),
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardPickerField(
                                        key: _coordinatorKey,
                                        label: 'Coordinator (CC)',
                                        icon: Icons.supervisor_account_rounded,
                                        isRequired: true,
                                        value: _ctrl.selectedCoordinatorLabel,
                                        enabled: !_ctrl.isSubmitting,
                                        onTap: () => _openPicker(
                                          title: 'Select Coordinator',
                                          items: _ctrl.coordinators,
                                          selectedId:
                                              _ctrl.selectedCoordinatorId,
                                          getId: (c) =>
                                              (c['fr_id'] as num?)?.toInt() ??
                                              0,
                                          getLabel: (c) =>
                                              '${c['fr_code']} - ${c['fr_name']}',
                                          searchKeys: const [
                                            'fr_code',
                                            'fr_name',
                                          ],
                                          onSelected: (id, label, [code]) =>
                                              _ctrl.setCoordinator(id, label),
                                        ),
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      HaulingStatusField(
                                        haulingStatus: _ctrl.haulingStatus,
                                        onToggle: _ctrl.setHaulingStatus,
                                        enabled: !_ctrl.isSubmitting,
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardTextField(
                                        key: _haulingAmountKey,
                                        controller: _ctrl.hlngqtyController,
                                        label: 'Hauling Amount',
                                        icon: Icons.numbers_rounded,
                                        keyboardType: TextInputType.number,
                                        enabled: !_ctrl.isSubmitting,
                                        isRequired: true,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'Required';
                                          }
                                          if (int.tryParse(v) == null ||
                                              int.parse(v) <= 0) {
                                            return 'Enter a valid quantity';
                                          }
                                          return null;
                                        },
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardPickerField(
                                        key: _cuttingModeKey,
                                        label: 'Cutting Mode',
                                        icon: Icons.content_cut_rounded,
                                        isRequired: true,
                                        value: _ctrl.selectedCuttingmodeLabel,
                                        enabled: !_ctrl.isSubmitting,
                                        onTap: () => _openPicker(
                                          title: 'Select Cutting Mode',
                                          items: _ctrl.cuttingmodes,
                                          selectedId:
                                              _ctrl.selectedCuttingmodeId,
                                          getId: (c) => c['id'] as int,
                                          getLabel: (c) =>
                                              '${c['description']}',
                                          searchKeys: const ['description'],
                                          onSelected: (id, label, [code]) =>
                                              _ctrl.setCuttingMode(id, label),
                                        ),
                                      ),
                                      Divider(height: 1, color: colors.border),
                                      CardDateField(
                                        key: _cuttingDateKey,
                                        label: 'Cutting Date',
                                        icon: Icons.calendar_month_rounded,
                                        displayValue: cuttingDateStr,
                                        onTap: _pickCuttingDate,
                                        isRequired: true,
                                        isComplete: _ctrl.cuttingDate != null,
                                        enabled: !_ctrl.isSubmitting,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Verification ───────────────
                                  const FormSectionHeader(
                                    icon: Icons.verified_rounded,
                                    label: 'Verification',
                                  ),
                                  const SizedBox(height: 12),

                                  VerificationCard(
                                    key: _signatureKey,
                                    title: 'Signature *',
                                    subtitle: _ctrl.signatureBytes != null
                                        ? 'Signature captured — tap to redo'
                                        : 'Tap to add planter signature',
                                    icon: Icons.draw_rounded,
                                    isComplete: _ctrl.signatureBytes != null,
                                    enabled: !_ctrl.isSubmitting,
                                    onTap: _openSignatureScreen,
                                    onPreview: _ctrl.signatureBytes != null
                                        ? _previewSignature
                                        : null,
                                    preview: _ctrl.signatureBytes != null
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                            child: Image.memory(
                                              _ctrl.signatureBytes!,
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              height: 90,
                                            ),
                                          )
                                        : null,
                                  ),

                                  const SizedBox(height: 12),

                                  VerificationCard(
                                    key: _deliveryProofKey,
                                    title: 'Delivery Proof *',
                                    subtitle: _ctrl.proofImage != null
                                        ? 'Photo captured — tap to retake'
                                        : 'Tap to take a photo',
                                    icon: Icons.camera_alt_rounded,
                                    isComplete: _ctrl.proofImage != null,
                                    enabled: !_ctrl.isSubmitting,
                                    onTap: _captureProof,
                                    onPreview: _ctrl.proofImage != null
                                        ? _previewProofImage
                                        : null,
                                    preview: _ctrl.proofImage != null
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                            child: Image.file(
                                              _ctrl.proofImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 150,
                                            ),
                                          )
                                        : null,
                                  ),

                                  const SizedBox(height: 12),

                                  VerificationCard(
                                    key: _seedProofKey,
                                    title: 'Seed Pieces Proof *',
                                    subtitle: _ctrl.proofSeedImage != null
                                        ? 'Photo captured — tap to retake'
                                        : 'Tap to take a photo',
                                    icon: Icons.camera_alt_rounded,
                                    isComplete: _ctrl.proofSeedImage != null,
                                    enabled: !_ctrl.isSubmitting,
                                    onTap: _captureSeedProof,
                                    onPreview: _ctrl.proofSeedImage != null
                                        ? _previewSeedProofImage
                                        : null,
                                    preview: _ctrl.proofSeedImage != null
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                            child: Image.file(
                                              _ctrl.proofSeedImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 150,
                                            ),
                                          )
                                        : null,
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Submit Button ──────────────
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: _ctrl.isSubmitting
                                            ? null
                                            : AppTheme.primaryGradient,
                                        color: _ctrl.isSubmitting
                                            ? colors.border
                                            : null,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusLG,
                                        ),
                                        boxShadow: _ctrl.isSubmitting
                                            ? []
                                            : AppTheme.shadowBrand(
                                                dark: context.isDark,
                                              ),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _ctrl.isSubmitting
                                            ? null
                                            : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusLG,
                                            ),
                                          ),
                                        ),
                                        child: _ctrl.isSubmitting
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.check_rounded,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Print',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                        8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
