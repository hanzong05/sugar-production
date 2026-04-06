import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class MenuGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuGrid({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(menuItems.length, (index) {
        final item = menuItems[index];
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _MenuGridItem(
            icon: item['icon'] as String,
            title: item['title'] as String,
            onTap: item['onTap'] as VoidCallback,
          ),
        );
      }),
    );
  }
}

class _MenuGridItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _MenuGridItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                border: Border.all(color: context.appColors.border, width: 1),
                boxShadow: AppTheme.shadowMD(dark: context.isDark),
              ),
              child: Center(
                child: SvgPicture.asset(icon, width: 64, height: 64),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
