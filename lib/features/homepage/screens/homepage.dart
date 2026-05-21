import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

import '../widgets/image_slider.dart';
import '../widgets/menu_grid.dart';
import '../controllers/homepage_controller.dart';

import '../../cprdelivery/screens/planters.dart' as cpr;
import '../../cprhistory/screens/cpr_history.dart';
import '../../lotpictures/screens/planters.dart' as lot;
import '../../statistics/screens/statistics.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = HomeController();

    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _menuItems {
    final all = [
      {
        'module_id': 1,
        'icon': 'assets/icons/cpr-delivery.svg',
        'title': 'Cane Points Delivery',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const cpr.PlanterScreen()),
          );
        },
      },
      {
        'module_id': 2,
        'icon': 'assets/icons/cpr-history.svg',
        'title': 'CPR Records',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CprsHistory()),
          );
        },
      },
      {
        'module_id': 3,
        'icon': 'assets/icons/lot-picture.svg',
        'title': 'CP Lot Pictures',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const lot.PlanterScreen()),
          );
        },
      },
      {
        'module_id': 4,
        'icon': 'assets/icons/statistics.svg',
        'title': 'Statistics',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
          );
        },
      },
    ];

    return all
        .where((item) => _ctrl.canAccess(item['module_id'] as int))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _ctrl.loadPermissions();
          },
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ImageSlider(),
                const SizedBox(height: 24),

                Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                _ctrl.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      )
                    : MenuGrid(menuItems: _menuItems),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
