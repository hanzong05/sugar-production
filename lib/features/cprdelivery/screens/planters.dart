import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/features/cprdelivery/controllers/planter_controller.dart';
import 'package:sugar_production/widgets/search_bar.dart';
import 'package:sugar_production/widgets/empty_state.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import '../widgets/planter_item.dart';

class PlanterScreen extends StatefulWidget {
  final VoidCallback? onBecomeVisible;

  const PlanterScreen({super.key, this.onBecomeVisible});

  @override
  PlanterScreenState createState() => PlanterScreenState();
}

class PlanterScreenState extends State<PlanterScreen> {
  late final PlanterController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PlanterController();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void reload() => _ctrl.loadData().catchError(_handleError);

  void _handleError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Error loading data: $e')),
          ],
        ),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(height: 30, color: AppTheme.primary),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.appColors.background,
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
                    resultCount: _ctrl.filteredPlanters.length,
                    onChanged: _ctrl.searchPlanters,
                    onClear: _ctrl.clearSearch,
                    hintText: 'Search planter name or code...',
                    resultLabel: 'planter',
                  ),
                  Expanded(
                    child: _ctrl.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : _ctrl.filteredPlanters.isEmpty
                        ? const AppEmptyState(
                            icon: Icons.person_off_outlined,
                            title: 'No planters found',
                          )
                        : PlanterList(
                            planters: _ctrl.filteredPlanters,
                            onRefresh: () =>
                                _ctrl.loadData().catchError(_handleError),
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
