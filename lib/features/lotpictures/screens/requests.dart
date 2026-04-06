import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/widgets/search_bar.dart';
import 'package:sugar_production/widgets/empty_state.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import '../controllers/request_controller.dart';
import '../widgets/request_list.dart';

class PlanterReqScreen extends StatefulWidget {
  final Planter planter;
  const PlanterReqScreen({super.key, required this.planter});

  @override
  _PlanterReqScreenState createState() => _PlanterReqScreenState();
}

class _PlanterReqScreenState extends State<PlanterReqScreen> {
  late final PlanterReqController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PlanterReqController(widget.planter.plcode);
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
                        : RequestList(
                            requests: _ctrl.filteredRequests,
                            planter: widget.planter,
                            onRefresh: () =>
                                _ctrl.loadData(widget.planter.plcode),
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
