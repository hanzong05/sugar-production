import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sugar_production/features/cprdelivery/controllers/planter_controller.dart';

import 'package:sugar_production/widgets/search_bar.dart';
import 'package:sugar_production/widgets/empty_state.dart';

import 'package:sugar_production/core/theme/app_theme.dart';

import '../widgets/planter_item.dart';

class PlanterScreen extends StatefulWidget {
  const PlanterScreen({super.key});

  @override
  State<PlanterScreen> createState() => _PlanterScreenState();
}

class _PlanterScreenState extends State<PlanterScreen> {
  late final PlanterController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = PlanterController();

    _ctrl.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _load();
  }

  Future<void> _load() async {
    try {
      await _ctrl.loadData();
    } catch (e) {
      _handleError(e);
    }
  }

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
      appBar: AppBar(
        title: const Text('CPR'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Column(
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
                : RefreshIndicator(
                    onRefresh: _load,
                    child: PlanterList(
                      planters: _ctrl.filteredPlanters,
                      onRefresh: _load,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
