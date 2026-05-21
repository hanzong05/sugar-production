import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sugar_production/models/modplanter.dart';

import 'package:sugar_production/widgets/search_bar.dart';
import 'package:sugar_production/widgets/empty_state.dart';

import 'package:sugar_production/core/theme/app_theme.dart';

import '../controllers/request_controller.dart';
import '../widgets/request_list.dart';

class PlanterReqScreen extends StatefulWidget {
  final Planter planter;

  const PlanterReqScreen({super.key, required this.planter});

  @override
  State<PlanterReqScreen> createState() => _PlanterReqScreenState();
}

class _PlanterReqScreenState extends State<PlanterReqScreen> {
  late final PlanterReqController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = PlanterReqController(widget.planter.plcode);

    _ctrl.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _load();
  }

  Future<void> _load() async {
    try {
      await _ctrl.loadData(widget.planter.plcode);
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

            Expanded(child: Text('Error loading requests: $e')),
          ],
        ),

        backgroundColor: AppTheme.accentRed,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

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
        title: Text(widget.planter.plname),

        backgroundColor: AppTheme.primary,

        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          AppSearchBar(
            controller: _ctrl.searchController,

            resultCount: _ctrl.filteredRequests.length,

            onChanged: _ctrl.searchRequests,

            onClear: _ctrl.clearSearch,

            hintText: 'Search by request no. or location...',

            resultLabel: 'request',
          ),

          Expanded(
            child: _ctrl.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : _ctrl.filteredRequests.isEmpty
                ? const AppEmptyState(
                    icon: Icons.inbox_outlined,

                    title: 'No requests found',
                  )
                : RefreshIndicator(
                    onRefresh: _load,

                    child: RequestList(
                      requests: _ctrl.filteredRequests,

                      planter: widget.planter,

                      onRefresh: _load,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
