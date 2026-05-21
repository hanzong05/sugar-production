import 'package:flutter/material.dart';
import 'package:sugar_production/features/cprdelivery/controllers/seed_delivery_controller.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import '../controllers/cpr_info_controller.dart';
import '../widgets/cpr_info_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class CprInfo extends StatefulWidget {
  final CPR cpr;
  final SeedDeliveryController? deliveryController;

  const CprInfo({
    super.key,
    required this.cpr,
    this.deliveryController, // 👈 NOT required
  });
  @override
  State<CprInfo> createState() => _CprInfoState();
}

class _CprInfoState extends State<CprInfo> {
  late CprInfoController _ctrl;

  String? signaturePath;
  String? imagePath;
  String? seedImagePath;

  bool _isImageExpanded = false;
  bool _isSignatureExpanded = false;
  bool _isSeedDeliveredExpanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = CprInfoController(widget.cpr);
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });

    signaturePath = widget.deliveryController?.signaturePath;
    imagePath = widget.deliveryController?.imagePath;
    seedImagePath = widget.deliveryController?.seedImagePath;
  }

  @override
  void didUpdateWidget(CprInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cpr.colcprid != widget.cpr.colcprid) {
      _ctrl.dispose();
      _ctrl = CprInfoController(widget.cpr);
      _ctrl.addListener(() {
        if (mounted) setState(() {});
      });
      _isImageExpanded = false;
      _isSignatureExpanded = false;
      _isSeedDeliveredExpanded = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPrint() {
    try {
      // _ctrl.print();
      _showSnackBar(
        'Printing ${widget.cpr.colccprrefno}...',
        isError: false,
        icon: Icons.print_rounded,
      );
    } catch (e) {
      _showSnackBar('Error printing: $e', isError: true);
    }
  }

  void _showSnackBar(
    String message, {
    required bool isError,
    IconData icon = Icons.error_outline_rounded,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cpr = widget.cpr;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CPR INFO'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

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
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Planter Information ──────────────────
                    const InfoSectionHeader(
                      icon: Icons.person_rounded,
                      label: 'Planter Information',
                    ),
                    const SizedBox(height: 10),
                    InfoCard(
                      rows: [
                        InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Planter',
                          value: _ctrl.planterName,
                        ),
                        InfoRow(
                          icon: Icons.tag_rounded,
                          label: 'Request #',
                          value: _ctrl.requestNumber,
                        ),
                        InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Lot Location',
                          value: _ctrl.lotLocation,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Delivery Details ─────────────────────
                    const InfoSectionHeader(
                      icon: Icons.local_shipping_rounded,
                      label: 'Delivery Details',
                    ),
                    const SizedBox(height: 10),
                    InfoCard(
                      rows: [
                        InfoRow(
                          icon: Icons.numbers_rounded,
                          label: 'Quantity',
                          value: cpr.colcprqty.toString(),
                        ),
                        InfoRow(
                          icon: Icons.eco_rounded,
                          label: 'Variety',
                          value: _ctrl.variety,
                        ),
                        InfoRow(
                          icon: Icons.content_cut_rounded,
                          label: 'Cutter',
                          value: _ctrl.cutter,
                        ),
                        InfoRow(
                          icon: Icons.warehouse_rounded,
                          label: 'Source Location',
                          value: _ctrl.sourceLocation,
                        ),
                        InfoRow(
                          icon: Icons.person_pin_rounded,
                          label: 'Source Planter',
                          value: _ctrl.sourcePlanter,
                        ),
                        InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Delivery Date',
                          value: _ctrl.formatDate(cpr.colcprdatedelivered),
                        ),
                        if (_ctrl
                            .formatTime(cpr.colcprdatedelivered)
                            .isNotEmpty)
                          InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Time',
                            value: _ctrl.formatTime(cpr.colcprdatedelivered),
                          ),
                        InfoRow(
                          icon: Icons.directions_car_rounded,
                          label: 'Delivered By',
                          value: _ctrl.deliveredByName,
                        ),
                        InfoRow(
                          icon: Icons.supervisor_account_rounded,
                          label: 'Coordinator',
                          value: _ctrl.coordinatorName,
                        ),
                        InfoRow(
                          icon: Icons.how_to_reg_rounded,
                          label: 'Received By',
                          value: _ctrl.receivedBy,
                        ),
                        InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Hauling Paid',
                          value: _ctrl.haulingPaid,
                        ),
                        InfoRow(
                          icon: Icons.monetization_on_outlined,
                          label: 'Hauling Amount',
                          value: _ctrl.haulingAmount,
                        ),
                        InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Cutting Paid',
                          value: _ctrl.cuttingPaid,
                        ),
                        InfoRow(
                          icon: Icons.monetization_on_outlined,
                          label: 'Cutting Amount',
                          value: _ctrl.cuttingAmount,
                        ),
                        InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Sacks Paid',
                          value: _ctrl.sacksPaid,
                        ),
                        InfoRow(
                          icon: Icons.monetization_on_outlined,
                          label: 'Sacks Amount',
                          value: _ctrl.sacksAmount,
                        ),
                        InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Others Paid',
                          value: _ctrl.othersPaid,
                        ),
                        InfoRow(
                          icon: Icons.monetization_on_outlined,
                          label: 'Others Amount',
                          value: _ctrl.othersAmount,
                        ),
                        InfoRow(
                          icon: Icons.content_cut_rounded,
                          label: 'Cutting Mode',
                          value: _ctrl.cuttingModeName,
                        ),
                        InfoRow(
                          icon: Icons.calendar_month_rounded,
                          label: 'Cutting Date',
                          value: _ctrl.formatDate(cpr.colcprcmdate),
                        ),
                        InfoRow(
                          icon: Icons.monetization_on_outlined,
                          label: 'Lot COde',
                          value: _ctrl.LotCode,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Delivery Proof ───────────────────────
                    const InfoSectionHeader(
                      icon: Icons.camera_alt_rounded,
                      label: 'Delivery Proof',
                    ),
                    const SizedBox(height: 10),

                    MediaCard(
                      type: 'pic',
                      cprNo: widget.cpr.colccprrefno,
                      isExpanded: _isImageExpanded,
                      onToggle: () =>
                          setState(() => _isImageExpanded = !_isImageExpanded),
                      emptyIcon: Icons.photo_camera_outlined,
                      fitMode: BoxFit.cover,
                    ),

                    const SizedBox(height: 20),

                    // ── Seed Pieces Delivered ────────────────
                    const InfoSectionHeader(
                      icon: Icons.draw_rounded,
                      label: 'Seed Pieces Delivered',
                    ),
                    const SizedBox(height: 10),
                    MediaCard(
                      type: 'spd',
                      cprNo: widget.cpr.colccprrefno,
                      isExpanded: _isSeedDeliveredExpanded,
                      onToggle: () => setState(
                        () => _isSeedDeliveredExpanded =
                            !_isSeedDeliveredExpanded,
                      ),
                      emptyIcon: Icons.draw_outlined,
                      fitMode: BoxFit.fill,
                      collapsedHeight: 100,
                      expandedHeight: 220,
                    ),

                    const SizedBox(height: 28),

                    // ── Signature ────────────────────────────
                    const InfoSectionHeader(
                      icon: Icons.draw_rounded,
                      label: 'Signature',
                    ),
                    const SizedBox(height: 10),
                    MediaCard(
                      type: 'sig',
                      cprNo: widget.cpr.colccprrefno,
                      isExpanded: _isSignatureExpanded,
                      onToggle: () => setState(
                        () => _isSignatureExpanded = !_isSignatureExpanded,
                      ),
                      emptyIcon: Icons.draw_outlined,
                      fitMode: BoxFit.fill,
                      collapsedHeight: 100,
                      expandedHeight: 220,
                    ),

                    const SizedBox(height: 28),

                    // ── Print Button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                          boxShadow: AppTheme.shadowBrand(dark: context.isDark),
                        ),
                        child: ElevatedButton(
                          onPressed: _onPrint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLG,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.print_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Print CPR',
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

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
