import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import '../controllers/signature_controller.dart';
import '../widgets/signature_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class SignatureScreen extends StatefulWidget {
  final String title;
  final String signerName;

  const SignatureScreen({
    super.key,
    this.title = 'Signature',
    this.signerName = '',
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey _signatureKey = GlobalKey();
  late final SignatureController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SignatureController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _clear() => _ctrl.clear();

  Future<void> _save() async {
    if (!_ctrl.isSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a signature first'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.appColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    try {
      final bytes = await _ctrl.capture(_signatureKey);
      if (bytes != null && mounted) Navigator.pop(context, bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving signature: $e'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: context.gradients.header,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _ctrl.isSigned ? _save : null,
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: _ctrl.isSigned ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Info strip ─────────────────────────────────────
          Container(
            color: colors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.draw_outlined,
                  color: colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.signerName.isNotEmpty
                        ? 'Signature for ${widget.signerName}'
                        : 'Please sign in the area below',
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.border),

          // ── Canvas ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SignatureCanvas(
                repaintKey: _signatureKey,
                controller: _ctrl,
                signerName: widget.signerName,
                onStartSign: () => setState(() {}),
              ),
            ),
          ),

          // ── Bottom actions ─────────────────────────────────
          SignatureBottomActions(
            isSigned: _ctrl.isSigned,
            onClear: _clear,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}
