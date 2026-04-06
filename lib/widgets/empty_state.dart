import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'No results found',
    this.subtitle = 'Try a different search term',
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.appColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: context.appColors.textHint),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: context.appColors.textHint),
          ),
        ],
      ),
    );
  }
}
