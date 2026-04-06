import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import '../controllers/sync_controller.dart';
import '../widgets/sync_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late final SyncController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SyncController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _sync(int conntype) async {
    // Show progress dialog — it reads live from _ctrl via StatefulBuilder
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            _ctrl.addListener(() {
              if (ctx.mounted) setDialogState(() {});
            });
            return SyncingDialog(
              progress: _ctrl.progress,
              statusText: _ctrl.statusText,
            );
          },
        ),
      ),
    );

    try {
      final success = await _ctrl.sync(context, conntype);
      if (mounted) {
        Navigator.of(context).pop(); // close progress dialog
        SyncResultDialog.show(
          context,
          success: success,
          message: success
              ? 'Data synchronized successfully'
              : _ctrl.statusText,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        SyncResultDialog.show(context, success: false, message: 'Error: $e');
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Select sync method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SyncOption(
                      icon: Icons.wifi_rounded,
                      title: 'Local Network',
                      subtitle: 'Sync via local WiFi connection',
                      onTap: _ctrl.isSyncing ? null : () => _sync(1),
                    ),
                    const SizedBox(height: 12),
                    SyncOption(
                      icon: Icons.cloud_outlined,
                      title: 'Internet',
                      subtitle: 'Sync via internet connection',
                      onTap: _ctrl.isSyncing ? null : () => _sync(2),
                    ),
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
