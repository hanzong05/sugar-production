import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import '../controllers/signature_controller.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// Signature Canvas
// ─────────────────────────────────────────────
class SignatureCanvas extends StatelessWidget {
  const SignatureCanvas({
    super.key,
    required this.repaintKey,
    required this.controller,
    required this.signerName,
    required this.onStartSign,
  });

  final GlobalKey repaintKey;
  final SignatureController controller;
  final String signerName;
  final VoidCallback onStartSign;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            key: repaintKey,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: controller.isSigned
                      ? AppTheme.primary.withOpacity(0.6)
                      : colors.border,
                  width: controller.isSigned ? 1.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: Stack(
                  children: [
                    GestureDetector(
                      onPanStart: (d) {
                        onStartSign();
                        controller.addPoint(d.localPosition);
                      },
                      onPanUpdate: (d) => controller.addPoint(d.localPosition),
                      onPanEnd: (_) => controller.endStroke(),
                      child: CustomPaint(
                        painter: SignaturePainter(
                          controller,
                          inkColor: colors.textPrimary,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                    if (!controller.isSigned)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.gesture,
                              size: 40,
                              color: colors.textHint,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign here',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Signer name line
        Row(
          children: [
            Expanded(child: Divider(color: colors.border, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                signerName.isNotEmpty ? signerName : 'Signature',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
            Expanded(child: Divider(color: colors.border, height: 1)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Signature Bottom Actions (Clear + Save)
// ─────────────────────────────────────────────
class SignatureBottomActions extends StatelessWidget {
  const SignatureBottomActions({
    super.key,
    required this.isSigned,
    required this.onClear,
    required this.onSave,
  });

  final bool isSigned;
  final VoidCallback onClear;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.surface,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSigned ? onClear : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isSigned ? colors.textSecondary : colors.border,
                ),
                foregroundColor: colors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isSigned ? AppTheme.primaryGradient : null,
                color: isSigned ? null : colors.border,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: ElevatedButton(
                onPressed: isSigned ? onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: colors.textHint,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
