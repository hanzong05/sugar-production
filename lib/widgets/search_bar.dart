import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.resultCount,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search...',
    this.resultLabel = 'result',
  });

  final TextEditingController controller;
  final int resultCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  /// Placeholder text inside the text field.
  final String hintText;

  /// Singular noun used in the count badge e.g. "planter" → "2 planters found".
  final String resultLabel;

  @override
  Widget build(BuildContext context) {
    final plural = resultCount != 1 ? '${resultLabel}s' : resultLabel;

    return Container(
      color: context.appColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.appColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: context.appColors.border),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: context.appColors.textHint,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.appColors.textHint,
                  size: 20,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.appColors.textHint,
                          size: 18,
                        ),
                        onPressed: onClear,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$resultCount $plural found',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
