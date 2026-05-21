import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

// ─────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────
class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
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
            color: colors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Form Card wrapper
// ─────────────────────────────────────────────
class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: context.appColors.border),
        boxShadow: AppTheme.shadowSM(dark: context.isDark),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

// ─────────────────────────────────────────────
// Shared required label
// ─────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.color,
    this.isRequired = false,
  });

  final String label;
  final Color color;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 13, color: color),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card Text Field
// ─────────────────────────────────────────────
class CardTextField extends StatelessWidget {
  const CardTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.enabled = true,
    this.isFirst = false,
    this.isLast = false,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool isFirst;
  final bool isLast;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
        topRight: isFirst ? const Radius.circular(16) : Radius.zero,
        bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        enabled: enabled,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
        decoration: InputDecoration(
          label: _FieldLabel(
            label: label,
            color: colors.textSecondary,
            isRequired: isRequired,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 12,
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? colors.textSecondary : colors.textHint,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          filled: true,
          fillColor: colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 11, color: AppTheme.accentRed),
        ),
        validator: validator,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card Date Field
// ─────────────────────────────────────────────
class CardDateField extends StatelessWidget {
  const CardDateField({
    super.key,
    required this.label,
    required this.icon,
    required this.displayValue,
    required this.onTap,
    this.isRequired = false,
    this.isComplete = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final String displayValue;
  final VoidCallback onTap;
  final bool isRequired;
  final bool isComplete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  icon,
                  size: 18,
                  color: enabled ? colors.textSecondary : colors.textHint,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(
                      label: label,
                      color: enabled ? colors.textSecondary : colors.textHint,
                      isRequired: isRequired,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isComplete
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: !enabled
                            ? colors.textHint
                            : isComplete
                            ? colors.textPrimary
                            : colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: enabled ? AppTheme.primary : colors.textHint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: enabled ? colors.textSecondary : colors.textHint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card Picker Field
// ─────────────────────────────────────────────
class CardPickerField extends StatelessWidget {
  const CardPickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.isRequired = false,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final bool isRequired;
  final bool isFirst;
  final bool isLast;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = value.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
        topRight: isFirst ? const Radius.circular(16) : Radius.zero,
        bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            color: colors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    icon,
                    size: 18,
                    color: enabled ? colors.textSecondary : colors.textHint,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                        label: label,
                        color: enabled ? colors.textSecondary : colors.textHint,
                        isRequired: isRequired,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasValue ? value : 'Not selected',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasValue
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: !enabled
                              ? colors.textHint
                              : hasValue
                              ? colors.textPrimary
                              : colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasValue)
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: enabled ? AppTheme.primary : colors.textHint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 20,
                    color: enabled ? colors.textSecondary : colors.textHint,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hauling Status Card Row
// ─────────────────────────────────────────────
class HaulingStatusField extends StatelessWidget {
  const HaulingStatusField({
    super.key,
    required this.haulingStatus,
    required this.onToggle,
    this.enabled = true,
  });

  final int haulingStatus;
  final void Function(int value) onToggle;
  final bool enabled;

  String get _statusLabel {
    if (haulingStatus == 1) return 'Yes';
    if (haulingStatus == 2) return 'No';
    return 'Not set';
  }

  Color _statusColor(BuildContext context) {
    if (haulingStatus == 1) return AppTheme.primary;
    if (haulingStatus == 2) return AppTheme.accentRed;
    return context.appColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = _statusColor(context);

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 18,
              color: enabled ? colors.textSecondary : colors.textHint,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hauling Status',
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled ? colors.textSecondary : colors.textHint,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _StatusToggle(
                label: 'Yes',
                value: 1,
                current: haulingStatus,
                activeColor: AppTheme.primary,
                enabled: enabled,
                onTap: onToggle,
              ),
              const SizedBox(width: 8),
              _StatusToggle(
                label: 'No',
                value: 2,
                current: haulingStatus,
                activeColor: AppTheme.accentRed,
                enabled: enabled,
                onTap: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({
    required this.label,
    required this.value,
    required this.current,
    required this.activeColor,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final int value;
  final int current;
  final Color activeColor;
  final void Function(int) onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isActive = current == value;
    final colors = context.appColors;

    return GestureDetector(
      onTap: enabled ? () => onTap(value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor
              : (enabled
                    ? colors.surfaceAlt
                    : colors.surfaceAlt.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(Icons.check_rounded, size: 13, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : (enabled ? colors.textSecondary : colors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
