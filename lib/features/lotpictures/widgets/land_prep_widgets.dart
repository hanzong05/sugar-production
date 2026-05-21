import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import 'dart:io';
import 'package:sugar_production/core/services/data.dart';

// ─────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────
class LpSectionHeader extends StatelessWidget {
  const LpSectionHeader({super.key, required this.icon, required this.label});

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
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.appColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Verification Card
// ─────────────────────────────────────────────
class LpVerificationCard extends StatelessWidget {
  const LpVerificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isComplete,
    required this.onTap,
    this.locked = false,
    this.disabled = false,
    this.onPreview,
    this.preview,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isComplete;
  final VoidCallback onTap;
  final bool locked;
  final bool disabled;
  final VoidCallback? onPreview;
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasAsterisk = title.endsWith(' *');
    final base = hasAsterisk ? title.substring(0, title.length - 2) : title;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      child: InkWell(
        borderRadius: preview != null
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : BorderRadius.circular(AppTheme.radiusLG),
        splashColor: AppTheme.primary.withOpacity(0.05),
        onTap: (disabled || locked) ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(
              color: isComplete
                  ? AppTheme.primary.withOpacity(0.4)
                  : colors.border,
              width: isComplete ? 1.5 : 1,
            ),
            boxShadow: AppTheme.shadowSM(dark: context.isDark),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isComplete ? AppTheme.primaryGradient : null,
                        color: isComplete ? null : colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isComplete ? Colors.white : colors.textHint,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: base,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isComplete
                                    ? AppTheme.primary
                                    : colors.textPrimary,
                              ),
                              children: hasAsterisk
                                  ? [
                                      const TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Preview button
                    if (onPreview != null) ...[
                      GestureDetector(
                        onTap: disabled ? null : onPreview,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: const Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Status icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: locked
                            ? Colors.orange.withOpacity(0.10)
                            : isComplete
                            ? AppTheme.primary.withOpacity(0.10)
                            : colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Icon(
                        locked
                            ? Icons.lock_rounded
                            : isComplete
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: locked
                            ? 14
                            : isComplete
                            ? 16
                            : 13,
                        color: locked
                            ? Colors.orange
                            : isComplete
                            ? AppTheme.primary
                            : colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              if (preview != null) ...[
                Divider(
                  height: 1,
                  color: isComplete
                      ? AppTheme.primary.withOpacity(0.15)
                      : colors.border,
                ),
                preview!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Media Card
// ─────────────────────────────────────────────
class MediaCard extends StatefulWidget {
  const MediaCard({
    super.key,
    required this.type,
    required this.requestId,
    required this.isExpanded,
    required this.onToggle,
    required this.emptyIcon,
    this.fitMode = BoxFit.cover,
    this.collapsedHeight = 160,
    this.expandedHeight = 320,
  });

  final String type;
  final String requestId;
  final bool isExpanded;
  final VoidCallback onToggle;
  final IconData emptyIcon;
  final BoxFit fitMode;
  final double collapsedHeight;
  final double expandedHeight;

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  // Initialised to false; _checkImage() will set the real value before
  // the first build completes via initState.
  bool _hasImage = false;

  String get _fullPath =>
      '/storage/emulated/0/DCIM/LOT_PICTURES/${widget.type}_${widget.requestId}.jpg';

  @override
  void initState() {
    super.initState();
    _checkImage();
    DataNotifier.instance.addListener(_onDataChanged);
  }

  @override
  void didUpdateWidget(MediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check if the type or requestId changed (e.g. list reuse).
    if (oldWidget.type != widget.type ||
        oldWidget.requestId != widget.requestId) {
      _checkImage();
    }
  }

  @override
  void dispose() {
    DataNotifier.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) _checkImage();
  }

  void _checkImage() {
    final exists = File(_fullPath).existsSync();
    // Only call setState when the value actually changed to avoid
    // unnecessary rebuilds.
    if (mounted && exists != _hasImage) {
      setState(() => _hasImage = exists);
    }
  }

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
        child: !_hasImage
            ? Container(
                height: 100,
                color: colors.surfaceAlt,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.emptyIcon, size: 30, color: colors.textHint),
                    const SizedBox(height: 8),
                    Text(
                      'No image available',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: widget.onToggle,
                child: Stack(
                  children: [
                    SizedBox(
                      height: widget.isExpanded
                          ? widget.expandedHeight
                          : widget.collapsedHeight,
                      width: double.infinity,
                      child: VerificationImage(
                        // Key forces Flutter to rebuild the image widget
                        // whenever the file path changes after a sync,
                        // bypassing the image cache for the old (missing) entry.
                        key: ValueKey(_fullPath),
                        type: widget.type,
                        requestId: widget.requestId,
                        fit: widget.fitMode,
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
                              widget.isExpanded
                                  ? Icons.unfold_less_rounded
                                  : Icons.unfold_more_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.isExpanded ? 'Collapse' : 'Expand',
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
// Verification Image
// ─────────────────────────────────────────────
class VerificationImage extends StatelessWidget {
  const VerificationImage({
    super.key,
    required this.type,
    required this.requestId,
    required this.fit,
  });

  final String type; // 'lp' or 'ap'
  final String requestId;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fileName = '${type}_$requestId.jpg';
    final fullPath = '/storage/emulated/0/DCIM/LOT_PICTURES/$fileName';

    debugPrint('LP full path: $fullPath');

    final file = File(fullPath);

    if (!file.existsSync()) {
      return const _ErrorPlaceholder(message: 'Image Not Found');
    }

    return Image.file(
      file,
      // ValueKey ensures Flutter discards the cached decode and re-reads
      // the file from disk after a sync downloads a new image.
      key: ValueKey(fullPath),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) =>
          const _ErrorPlaceholder(message: 'Failed to Load'),
    );
  }
}

// ─────────────────────────────────────────────
// Error Placeholder
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// Date Field
// ─────────────────────────────────────────────
class LpDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final bool locked;
  final bool disabled;
  final VoidCallback? onTap;

  const LpDateField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    this.locked = false,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final formatted = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/'
              '${value!.month.toString().padLeft(2, '0')}/'
              '${value!.year}'
        : 'Select date';

    return GestureDetector(
      onTap: (disabled || locked) ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: locked
                ? AppTheme.primary.withOpacity(0.4)
                : value != null
                ? AppTheme.primary.withOpacity(0.6)
                : colors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock_rounded : icon,
              size: 20,
              color: locked
                  ? AppTheme.primary.withOpacity(0.5)
                  : value != null
                  ? AppTheme.primary
                  : colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatted,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!locked)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
