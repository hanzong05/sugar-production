import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/widgets/search_bar.dart';
import 'package:sugar_production/widgets/empty_state.dart';
import '../controllers/cpr_history_controller.dart';
import '../widgets/cpr_history_widgets.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class CprsHistory extends StatefulWidget {
  final void Function(CPR cpr)? onCprTap;

  const CprsHistory({super.key, this.onCprTap});

  @override
  State<CprsHistory> createState() => _CprsHistoryState();
}

class _CprsHistoryState extends State<CprsHistory> {
  late final CprHistoryController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CprHistoryController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
      backgroundColor: AppTheme.primary,
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
              child: Column(
                children: [
                  AppSearchBar(
                    controller: _ctrl.searchController,
                    resultCount: _ctrl.filteredCprs.length,
                    onChanged: _ctrl.searchCprs,
                    onClear: _ctrl.clearSearch,
                    hintText: 'Search by CPR number or planter name...',
                    resultLabel: 'record',
                  ),

                  Divider(height: 1, color: colors.border),

                  Expanded(
                    child: _ctrl.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : _ctrl.filteredCprs.isEmpty
                        ? const AppEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No records found',
                          )
                        : CprList(
                            cprs: _ctrl.filteredCprs,
                            onRefresh: _ctrl.loadCprs,
                            onTap: widget.onCprTap ?? (_) {},
                            formatDate: _ctrl.formatDate,
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
