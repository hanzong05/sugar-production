import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'dart:io';

// ─────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────
class InfoSectionHeader extends StatelessWidget {
  const InfoSectionHeader({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Icon(icon, size: 15, color: AppTheme.primary),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.appColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Info Card (wraps rows with dividers)
// ─────────────────────────────────────────────
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: colors.border),
        boxShadow: AppTheme.shadowSM(dark: context.isDark),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, color: colors.border, indent: 52),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info Row
// ─────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Media Card (expandable base64 image)
// ─────────────────────────────────────────────
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.type,
    required this.cprNo,
    required this.isExpanded,
    required this.onToggle,
    required this.emptyIcon,
    this.fitMode = BoxFit.cover,
    this.collapsedHeight = 160,
    this.expandedHeight = 320,
  });
  final String type;
  final String cprNo;
  final bool isExpanded;
  final VoidCallback onToggle;
  final IconData emptyIcon;
  final BoxFit fitMode;
  final double collapsedHeight;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: colors.border),
        boxShadow: AppTheme.shadowSM(dark: context.isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: GestureDetector(
          onTap: onToggle,
          child: Stack(
            children: [
              SizedBox(
                height: isExpanded ? expandedHeight : collapsedHeight,
                width: double.infinity,
                child: VerificationImage(
                  type: type, // 👈 hardcode or from cpr
                  cprNo: cprNo,
                  fit: fitMode,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.unfold_less_rounded
                            : Icons.unfold_more_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpanded ? 'Collapse' : 'Expand',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Base64 Image (private helper)
// ─────────────────────────────────────────────
class VerificationImage extends StatelessWidget {
  const VerificationImage({
    super.key,
    required this.type,
    required this.cprNo,
    required this.fit,
  });

  final String type;
  final String cprNo;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // 🔥 HARD CODE FILE NAME
    final fileName = '${type}_$cprNo.jpg';

    // 🔥 HARD CODE DIRECTORY
    final fullPath = '//storage/emulated/0/DCIM/CPR_IMAGES/$fileName';

    debugPrint('Generated path: $fullPath');

    final file = File(fullPath);

    if (!file.existsSync()) {
      return const _ErrorPlaceholder(message: "Image Not Found");
    }

    return Image.file(
      file,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) =>
          const _ErrorPlaceholder(message: 'Failed to Load'),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.surfaceAlt,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded, size: 30, color: colors.textHint),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: colors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
