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
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        itemCount: planters.length,

        itemBuilder: (context, index) {
          return _PlanterItem(planter: planters[index]);
        },
      ),
    );
  }
}

class _PlanterItem extends StatelessWidget {
  const _PlanterItem({required this.planter});

  final Planter planter;

  @override
  Widget build(BuildContext context) {
    final name = planter.plname ?? 'Unknown Planter';

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlanterReqScreen(planter: planter)),
        );
      },

      splashColor: AppTheme.primary.withOpacity(0.06),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.border, width: 0.8),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,

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

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),

                  ...[
                    const SizedBox(height: 3),

                    Text(
                      planter.plcode!,

                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: context.appColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
