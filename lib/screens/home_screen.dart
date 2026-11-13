import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../domain/growth.dart';
import '../models/plan.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final plan = state.selectedPlan;

    return AppScreen(
      showBack: false,
      center: false,
      footer: PrimaryButton(
        label: l.homePack,
        onPressed: plan == null
            ? () => Navigator.of(context).pushNamed('/family')
            : () => Navigator.of(context).pushNamed('/pack'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.homeTitle, style: AppType.h1),
          const SizedBox(height: 8),
          Text(l.homeSubtitle, style: AppType.body),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/emergency'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ink),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.grabGo, style: AppType.option),
                        const SizedBox(height: 3),
                        Text(l.grabGoSub, style: AppType.small),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (plan == null) ...[
            Text(l.planUnavailable, style: AppType.body),
            const SizedBox(height: 16),
            QuietLink(
              label: l.homeRestart,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/family'),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.tier == PlanTier.comfort ? l.comfort : l.essential,
                    style: AppType.option,
                  ),
                ),
                Text(
                  formatMoney(plan.totalPrice.roundToDouble(), state.locale),
                  style: AppType.price,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.nextReview(
                formatLongDate(
                  plan.bags.values
                      .map((bag) => project(bag.person).nextReview)
                      .reduce((a, b) => a.isBefore(b) ? a : b),
                  state.locale,
                ),
              ),
              style: AppType.small,
            ),
            const SizedBox(height: 16),
            for (final bag in plan.bags.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(bag.person.name, style: AppType.input),
                    ),
                    Text(
                      l.bagWeight(
                        formatWeight(bag.weightKg),
                        formatWeight(bag.limitKg),
                      ),
                      style: AppType.small,
                    ),
                  ],
                ),
              ),
            const Hairline(),
            const SizedBox(height: 18),
            QuietLink(
              label: l.homePlan,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/plan'),
            ),
            QuietLink(
              label: l.homeOrder,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/order'),
            ),
            QuietLink(
              label: l.openChecklist,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/checklist'),
            ),
            QuietLink(
              label: l.homeSettings,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            QuietLink(
              label: l.homeRestart,
              textAlign: TextAlign.left,
              onTap: () => _restart(context, state),
            ),
          ],
          if (state.subscriptionActive) ...[
            const SizedBox(height: 10),
            Text(
              l.subscribed(
                formatMoney(
                  state.subscriptionQuote.totalEur.roundToDouble(),
                  state.locale,
                ),
              ),
              style: AppType.small.copyWith(color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _restart(BuildContext context, AppState state) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(),
        backgroundColor: AppColors.white,
        title: Text(l.deleteTitle, style: AppType.row.copyWith(fontSize: 20)),
        content: Text(l.deleteBody, style: AppType.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l.cancel.toUpperCase(),
              style: AppType.label.copyWith(color: AppColors.ink),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l.delete.toUpperCase(),
              style: AppType.label.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await state.deleteAll();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }
}
