import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import '../widgets/image_slider.dart';
import '../widgets/menu_grid.dart';
import '../controllers/homepage_controller.dart';
import 'package:sugar_production/layout.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

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
    final layout = context.findAncestorStateOfType<AppLayoutState>();
    final all = [
      {
        'module_id': 1,
        'icon': 'assets/icons/cpr-delivery.svg',
        'title': 'Cane Points Delivery',
        'onTap': () => layout?.navigateToCPRDelivery(),
      },
      {
        'module_id': 2,
        'icon': 'assets/icons/cpr-history.svg',
        'title': 'CPR Records',
        'onTap': () => layout?.navigateTo(kIndexHistory),
      },
      {
        'module_id': 3,
        'icon': 'assets/icons/lot-picture.svg',
        'title': 'CP Lot Pictures',
        'onTap': () => layout?.navigateToLotPictures(),
      },
      {
        'module_id': 4,
        'icon': 'assets/icons/statistics.svg',
        'title': 'Statistics',
        'onTap': () => layout?.navigateTo(kIndexStatistics),
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  0,
                  20,
                  0,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image Slider ──────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ImageSlider(),
                    ),

                    const SizedBox(height: 24),

                    // ── Menu Label ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Menu Grid ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ctrl.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : MenuGrid(menuItems: _menuItems),
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
