import 'package:flutter/material.dart';

import 'package:sugar_production/models/modplanter.dart';

import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

import '../screens/requests.dart';

class PlanterList extends StatelessWidget {
  const PlanterList({
    super.key,
    required this.planters,
    required this.onRefresh,
  });

  final List<Planter> planters;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primary,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),

        itemCount: planters.length,

        itemBuilder: (context, index) {
          return _PlanterItem(planter: planters[index]);
        },
      ),
    );
  }
}

class _PlanterItem extends StatefulWidget {
  const _PlanterItem({required this.planter});

  final Planter planter;

  @override
  State<_PlanterItem> createState() => _PlanterItemState();
}

class _PlanterItemState extends State<_PlanterItem> {
  bool _isPressed = false;

  Future<void> _openPlanter() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanterReqScreen(planter: widget.planter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final name = widget.planter.plname ?? 'Unknown Planter';

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    final planterCode = widget.planter.plcode ?? 'No Code';

    return InkWell(
      onTapDown: (_) => setState(() => _isPressed = true),

      onTapUp: (_) async {
        setState(() => _isPressed = false);
        await _openPlanter();
      },

      onTapCancel: () => setState(() => _isPressed = false),

      splashColor: AppTheme.primary.withOpacity(0.05),

      borderRadius: BorderRadius.circular(AppTheme.radiusLG),

      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,

        duration: const Duration(milliseconds: 120),

        curve: Curves.easeInOut,

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: colors.surface,

            borderRadius: BorderRadius.circular(AppTheme.radiusLG),

            border: Border.all(color: colors.border),

            boxShadow: AppTheme.shadowSM(dark: context.isDark),
          ),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,

                  shape: BoxShape.circle,
                ),

                child: Center(
                  child: Text(
                    initial,

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 13,
                          color: colors.textHint,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            planterCode,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: colors.surfaceAlt,

                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),

                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textHint,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
