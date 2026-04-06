import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/features/camera/screens/camera_capture.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import '../controllers/land_prep_controller.dart';
import '../widgets/land_prep_widgets.dart';

class LandPrepVerificationForm extends StatefulWidget {
  final Map<String, dynamic> request;
  final Planter planter;
  final VoidCallback? onSubmitSuccess;

  const LandPrepVerificationForm({
    super.key,
    required this.request,
    required this.planter,
    this.onSubmitSuccess,
  });

  @override
  State<LandPrepVerificationForm> createState() =>
      _LandPrepVerificationFormState();
}

class _LandPrepVerificationFormState extends State<LandPrepVerificationForm> {
  final _formKey = GlobalKey<FormState>();
  late final LandPrepController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = LandPrepController(
      request: widget.request,
      planter: widget.planter,
    );
    // ✅ Listener first, THEN load
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl
        .loadExistingImages(); // ← now the listener is guaranteed to be attached
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Camera navigation ──────────────────────────────────────────

  Future<void> _captureLandPrep() async {
    final img = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCaptureScreen(
          title: 'Land Prep Photo',
          description: 'Take a photo of land preparation done before cutting',
        ),
      ),
    );
    if (img != null) _ctrl.setLandPrepImage(img);
  }

  Future<void> _capturePlantedArea() async {
    final img = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCaptureScreen(
          title: 'Planted Area Photo',
          description: 'Take a photo of the actual planted area',
        ),
      ),
    );
    if (img != null) _ctrl.setPlantedAreaImage(img);
  }

  // ── Preview dialogs ────────────────────────────────────────────

  void _previewLandPrep() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: MediaCard(
          type: 'lp',
          requestId: _ctrl.requestId.toString(),
          isExpanded: false,
          onToggle: () {},
          emptyIcon: Icons.landscape_rounded,
        ),
      ),
    );
  }

  void _previewPlantedArea() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: MediaCard(
          type: 'ap',
          requestId: _ctrl.requestId.toString(),
          isExpanded: false,
          onToggle: () {},
          emptyIcon: Icons.landscape_rounded,
        ),
      ),
    );
  }

  //pick date
  Future<void> _pickDate({
    required DateTime? current,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null) onPicked(picked);
  }

  // ── Submit ─────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await _ctrl.submit();
    if (!mounted) return;
    if (error == null) {
      _showSnackBar('Verification submitted successfully!', isError: false);
      widget.onSubmitSuccess?.call();
    } else {
      _showSnackBar(error, isError: true);
    }
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

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Widget photoPreview(File? img) => img != null
        ? ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Image.file(
              img,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 160,
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Land Prep ──────────────────────────────
                      const LpSectionHeader(
                        icon: Icons.landscape_rounded,
                        label: 'Land Preparation',
                      ),
                      const SizedBox(height: 12),
                      LpVerificationCard(
                        title: 'Land Prep Photo *',
                        subtitle: _ctrl.landPrepLocked
                            ? 'Verified — cannot retake\n${_ctrl.formatDate(_ctrl.landPrepDate)}'
                            : _ctrl.landPrepImage != null
                            ? 'Photo captured — tap to retake\n${_ctrl.formatDate(_ctrl.landPrepDate)}'
                            : 'Capture land prep done before cutting',
                        icon: Icons.camera_alt_rounded,
                        isComplete: _ctrl.landPrepImage != null,
                        locked: _ctrl.landPrepLocked,
                        disabled: _ctrl.isSubmitting,
                        onTap: _captureLandPrep,
                        onPreview: _ctrl.landPrepImage != null
                            ? _previewLandPrep
                            : null,
                        preview: _ctrl.landPrepImage != null
                            ? photoPreview(_ctrl.landPrepImage)
                            : null,
                      ),

                      // ── After the Land Prep photo card ──
                      const SizedBox(height: 12),
                      LpDateField(
                        key: ValueKey('lp_date_${_ctrl.landPrepInputDate}'),
                        label: 'Land Prep Date *',
                        icon: Icons.event_rounded,
                        value: _ctrl.landPrepInputDate,
                        locked: _ctrl.landPrepLocked,
                        disabled: _ctrl.isSubmitting,
                        onTap: _ctrl.landPrepLocked
                            ? null
                            : () => _pickDate(
                                current: _ctrl.landPrepInputDate,
                                onPicked: _ctrl.setLandPrepInputDate,
                              ),
                      ),
                      const SizedBox(height: 12),

                      // ── Planted Area ───────────────────────────
                      const LpSectionHeader(
                        icon: Icons.straighten_rounded,
                        label: 'Planted Area',
                      ),
                      const SizedBox(height: 12),
                      LpVerificationCard(
                        title: 'Planted Area Photo',
                        subtitle: _ctrl.plantedAreaLocked
                            ? 'Verified — cannot retake\n${_ctrl.formatDate(_ctrl.plantedAreaDate)}'
                            : _ctrl.plantedAreaImage != null
                            ? 'Photo captured — tap to retake\n${_ctrl.formatDate(_ctrl.plantedAreaDate)}'
                            : 'Take a photo of the actual planted area',
                        icon: Icons.camera_alt_rounded,
                        isComplete: _ctrl.plantedAreaImage != null,
                        locked: _ctrl.plantedAreaLocked,
                        disabled: _ctrl.isSubmitting,
                        onTap: _capturePlantedArea,
                        onPreview: _ctrl.plantedAreaImage != null
                            ? _previewPlantedArea
                            : null,
                        preview: _ctrl.plantedAreaImage != null
                            ? photoPreview(_ctrl.plantedAreaImage)
                            : null,
                      ),

                      const SizedBox(height: 12),

                      // ── After the Planted Area photo card ──
                      LpDateField(
                        key: ValueKey('ap_date_${_ctrl.plantedInputDate}'),
                        label: 'Planted Date',
                        icon: Icons.calendar_today_rounded,
                        value: _ctrl.plantedInputDate,
                        locked: _ctrl.plantedAreaLocked,
                        disabled: _ctrl.isSubmitting,
                        onTap: _ctrl.plantedAreaLocked
                            ? null
                            : () => _pickDate(
                                current: _ctrl.plantedInputDate,
                                onPicked: _ctrl.setPlantedInputDate,
                              ),
                      ),

                      const SizedBox(height: 12),
                      // ── Submit Button ──────────────────────────
                      if (!(_ctrl.landPrepLocked && _ctrl.plantedAreaLocked))
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _ctrl.isSubmitting
                                  ? null
                                  : AppTheme.primaryGradient,
                              color: _ctrl.isSubmitting ? colors.border : null,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLG,
                              ),
                              boxShadow: _ctrl.isSubmitting
                                  ? []
                                  : AppTheme.shadowBrand(dark: context.isDark),
                            ),
                            child: ElevatedButton(
                              onPressed: _ctrl.isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.transparent,
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Submit Verification',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
