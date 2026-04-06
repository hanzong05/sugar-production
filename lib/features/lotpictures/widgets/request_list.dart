import 'package:flutter/material.dart';
import 'package:sugar_production/models/modplanter.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';
import '../screens/landprep_form.dart';

class RequestList extends StatelessWidget {
  const RequestList({
    super.key,
    required this.requests,
    required this.planter,
    required this.onRefresh,
  });

  final List<dynamic> requests;
  final Planter planter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primary,
      strokeWidth: 2.5,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: requests.length,
        itemBuilder: (context, index) => _RequestItem(
          request: requests[index] as Map<String, dynamic>,
          planter: planter,
          index: index,
        ),
      ),
    );
  }
}

class _RequestItem extends StatefulWidget {
  const _RequestItem({
    required this.request,
    required this.planter,
    required this.index,
  });

  final Map<String, dynamic> request;
  final Planter planter;
  final int index;

  @override
  State<_RequestItem> createState() => _RequestItemState();
}

class _RequestItemState extends State<_RequestItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (widget.index * 0.08).clamp(0.0, 0.6),
        ((widget.index * 0.08) + 0.4).clamp(0.4, 1.0),
        curve: Curves.easeOut,
      ),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final remaining =
        (widget.request['remaining_qty'] as num?)?.toDouble() ?? 0.0;
    final total = (widget.request['total_qty'] as num?)?.toDouble() ?? 0.0;
    final delivered =
        (widget.request['delivered_qty'] as num?)?.toDouble() ?? 0.0;
    final progress = total > 0 ? delivered / total : 0.0;
    final isFulfilled = remaining <= 0;

    final statusColor = isFulfilled ? AppTheme.primary : AppTheme.accentAmber;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              splashColor: AppTheme.primary.withOpacity(0.05),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LandPrepVerificationForm(
                      request: widget.request,
                      planter: widget.planter,
                    ),
                  ),
                );
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    border: Border.all(
                      color: isFulfilled
                          ? AppTheme.primary.withOpacity(0.4)
                          : colors.border,
                      width: isFulfilled ? 1.5 : 1,
                    ),
                    boxShadow: AppTheme.shadowSM(dark: context.isDark),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    child: Column(
                      children: [
                        // Accent bar — primaryGradient when fulfilled, amber when pending
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: isFulfilled
                                ? AppTheme.primaryGradient
                                : LinearGradient(
                                    colors: [
                                      AppTheme.accentAmber,
                                      AppTheme.accentAmber.withOpacity(0.4),
                                    ],
                                  ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row — mirrors VerificationCard layout
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon container — gradient when fulfilled, surfaceAlt when pending
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      gradient: isFulfilled
                                          ? AppTheme.primaryGradient
                                          : null,
                                      color: isFulfilled
                                          ? null
                                          : colors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMD,
                                      ),
                                    ),
                                    child: Icon(
                                      isFulfilled
                                          ? Icons.check_circle_rounded
                                          : Icons.pending_rounded,
                                      size: 20,
                                      color: isFulfilled
                                          ? Colors.white
                                          : colors.textHint,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Request #${widget.request['request_no']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isFulfilled
                                                ? AppTheme.primary
                                                : colors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_rounded,
                                              size: 12,
                                              color: colors.textHint,
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                widget.request['lot_location'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colors.textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Status pill + arrow chip — mirrors VerificationCard trailing
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          isFulfilled ? 'Fulfilled' : 'Pending',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: isFulfilled
                                              ? AppTheme.primary.withOpacity(
                                                  0.10,
                                                )
                                              : colors.surfaceAlt,
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSM,
                                          ),
                                        ),
                                        child: Icon(
                                          isFulfilled
                                              ? Icons.check_rounded
                                              : Icons.arrow_forward_ios_rounded,
                                          size: isFulfilled ? 16 : 13,
                                          color: isFulfilled
                                              ? AppTheme.primary
                                              : colors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Divider(height: 1, color: colors.border),

                              const SizedBox(height: 14),

                              // Stats row
                              Row(
                                children: [
                                  _StatChip(
                                    label: 'Total',
                                    value: _formatQty(total),
                                    color: colors.textSecondary,
                                    bgColor: colors.surfaceAlt,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    label: 'Delivered',
                                    value: _formatQty(delivered),
                                    color: AppTheme.primary,
                                    bgColor: AppTheme.primary.withOpacity(0.08),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    label: 'Remaining',
                                    value: _formatQty(remaining),
                                    color: statusColor,
                                    bgColor: statusColor.withOpacity(0.08),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Progress label row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery progress',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textHint,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  Text(
                                    '${(progress.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Progress bar
                              Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colors.border,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progress.clamp(0.0, 1.0),
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: isFulfilled
                                            ? AppTheme.primaryGradient
                                            : LinearGradient(
                                                colors: [
                                                  AppTheme.accentAmber,
                                                  AppTheme.accentAmber
                                                      .withOpacity(0.7),
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: statusColor.withOpacity(
                                              0.35,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double value) {
    if (value == value.truncate()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
