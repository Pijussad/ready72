import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../config/app_config.dart';
import '../data/lt72.dart';
import '../l10n/app_localizations.dart';
import '../models/needs.dart';
import '../models/plan.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../utils/labels.dart';
import '../widgets/common.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _showDropped(BuildContext context, AppLocalizations l, PlanResult plan) {
    showQuietSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LabelText(l.droppedTitle),
          const SizedBox(height: 12),
          Text(l.droppedWhy, style: AppType.body),
          const SizedBox(height: 16),
          for (final item in plan.dropped)
            Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
              child: Text(item, style: AppType.input),
            ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: l.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final plan = state.selectedPlan;
    final price = plan == null
        ? formatMoney(0, state.locale)
        : formatMoney(plan.totalPrice.roundToDouble(), state.locale);

    return AppScreen(
      step: '04',
      center: false,
      footer: PrimaryButton(
        label: l.reviewOrderCta(price),
        onPressed: plan == null
            ? null
            : () => Navigator.of(context).pushNamed('/order'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l.planTitle1}\n${l.planTitle2}', style: AppType.h1),
          const SizedBox(height: 28),
          if (plan == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(state.planError ?? l.planUnavailable, style: AppType.body),
                const SizedBox(height: 12),
                QuietLink(
                  label: l.back,
                  textAlign: TextAlign.left,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            )
          else ...[
            if (!state.household.any(
              (person) => person.isAdult || person.isSenior,
            )) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ink),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.noAdultTitle, style: AppType.input),
                    const SizedBox(height: 4),
                    Text(l.noAdultBody, style: AppType.small),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            _TierRow(
              key: const ValueKey('comfort'),
              title: l.comfort,
              subtitle: l.comfortSub,
              price: formatMoney(
                state.comfortPlan!.totalPrice.roundToDouble(),
                state.locale,
              ),
              selected: state.tier == PlanTier.comfort,
              onTap: () => state.selectTier(PlanTier.comfort),
            ),
            _TierRow(
              key: const ValueKey('essential'),
              title: l.essential,
              subtitle: l.essentialSub,
              price: formatMoney(
                state.essentialPlan!.totalPrice.roundToDouble(),
                state.locale,
              ),
              selected: state.tier == PlanTier.essential,
              onTap: () => state.selectTier(PlanTier.essential),
            ),
            const Hairline(),
            const SizedBox(height: 18),
            if (plan.everyBagWithinLimit) LabelText(l.everyBagWithin),
            const SizedBox(height: 4),
            Text(l.planWhy, style: AppType.small),
            if (plan.gaps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l.planGaps(
                  plan.gaps.map((gap) => categoryLabel(l, gap)).join(', '),
                ),
                style: AppType.small.copyWith(color: AppColors.ink),
              ),
            ],
            const SizedBox(height: 18),
            for (final bag in plan.bags.values) _PersonBagRow(bag: bag),
            const SizedBox(height: 16),
            Text(
              l.coverageLabel,
              style: AppType.label.copyWith(letterSpacing: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              l.criticalCount(
                plan.coveredCategories.intersection(criticalCategories).length,
                criticalCategories.length,
              ),
              style: AppType.small,
            ),
            if (plan.guardrails.blockersFired > 0) ...[
              const SizedBox(height: 12),
              Text(
                l.planIncomplete,
                style: AppType.small.copyWith(color: AppColors.ink),
              ),
            ],
            if (plan.dropped.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l.planDroppedCount(plan.dropped.length),
                style: AppType.small,
              ),
              QuietLink(
                label: l.viewDropped,
                textAlign: TextAlign.left,
                onTap: () => _showDropped(context, l, plan),
              ),
            ],
            if (state.needs.byPerson.isNotEmpty) ...[
              const SizedBox(height: 18),
              LabelText(l.needsUnderstood),
              const SizedBox(height: 8),
              for (final entry in state.needs.byPerson.entries)
                if (entry.value.hasAny)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '${_nameFor(state, entry.key)} · '
                      '${_needLabels(l, entry.value)}',
                      style: AppType.small.copyWith(color: AppColors.ink),
                    ),
                  ),
            ],
            const SizedBox(height: 18),
            Text(l.waterNote, style: AppType.small),
            const SizedBox(height: 14),
            LabelText(l.bringFromHome),
            const SizedBox(height: 6),
            Text(l.bringFromHomeList, style: AppType.small),
            const SizedBox(height: 14),
            QuietLink(
              label: l.lt72List,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/lt72'),
            ),
            QuietLink(
              label: l.lt72SourceCount(lt72Items.length),
              textAlign: TextAlign.left,
              onTap: () async {
                final uri = Uri.tryParse(AppConfig.lt72SourceUrl);
                if (uri == null) return;
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
            ),
          ],
        ],
      ),
    );
  }

  String _nameFor(AppState state, String id) {
    for (final person in state.household) {
      if (person.id == id) return person.name;
    }
    return id;
  }

  String _needLabels(AppLocalizations l, PersonNeeds needs) {
    final labels = <String>[
      for (final token in <String>{
        ...needs.conditions,
        ...needs.medications,
        ...needs.allergies,
        ...needs.diets,
      })
        conditionLabel(l, token),
      if (needs.glasses) conditionLabel(l, 'glasses'),
      if (needs.mobilityAid) conditionLabel(l, 'mobility'),
      if (needs.pregnant) conditionLabel(l, 'pregnancy'),
      if (needs.diapers || needs.formula || needs.babyFood)
        conditionLabel(l, 'baby'),
    ];
    return labels.isEmpty ? l.needsNone : labels.join(' · ');
  }
}

class _PersonBagRow extends StatelessWidget {
  const _PersonBagRow({required this.bag});

  final PersonBag bag;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ratio = bag.fillRatio.clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.bagLine(
                    bag.person.name,
                    formatWeight(bag.weightKg),
                    formatWeight(bag.limitKg),
                  ),
                  style: AppType.input,
                ),
              ),
              Text(l.itemsCount(bag.itemCount), style: AppType.small),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 2,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: AppColors.hairline),
                ),
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: ratio),
                    duration: MediaQuery.of(context).disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        widthFactor: value.clamp(0.0, 1.0),
                        alignment: Alignment.centerLeft,
                        child: child,
                      );
                    },
                    child: const ColoredBox(color: AppColors.ink),
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

class _TierRow extends StatelessWidget {
  const _TierRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $price',
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectSquare(selected: selected, size: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppType.option.copyWith(
                        fontWeight: selected
                            ? FontWeight.w400
                            : FontWeight.w300,
                        color: selected ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppType.small),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                price,
                style: AppType.price.copyWith(
                  color: selected ? AppColors.ink : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
