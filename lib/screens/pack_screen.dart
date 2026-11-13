import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../data/advice.dart';
import '../domain/growth.dart';
import '../l10n/app_localizations.dart';
import '../models/plan.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class PackScreen extends StatelessWidget {
  const PackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final person = state.packPerson;
    final plan = state.selectedPlan;

    if (person == null || plan == null) {
      return AppScreen(
        step: '07',
        footer: PrimaryButton(
          label: l.back,
          onPressed: () => Navigator.of(context).pushNamed('/home'),
        ),
        child: Text(l.noItems, style: AppType.body),
      );
    }

    final bag = plan.bags[person.id];
    final items = plan.itemsForCarrier(person.id).toList()
      ..sort((a, b) {
        final byPriority = a.product.priority.index.compareTo(
          b.product.priority.index,
        );
        if (byPriority != 0) return byPriority;
        return a.product
            .name(state.locale)
            .compareTo(b.product.name(state.locale));
      });

    final checked = items
        .where((item) => state.pack.entryFor(item.key).checked)
        .toList();
    final checkedUnits = checked.fold(0, (sum, item) => sum + item.quantity);
    final totalUnits = items.fold(0, (sum, item) => sum + item.quantity);
    final allPacked = items.isNotEmpty && checked.length == items.length;
    final checkedWeight = checked.fold(0.0, (sum, item) => sum + item.weightKg);
    final limit = bag?.limitKg ?? 0;
    final growth = project(person);
    final advice = adviceForGroup(
      person.isToddler
          ? 'toddler'
          : person.isChild
          ? 'child'
          : person.isSenior
          ? 'senior'
          : 'all',
    );

    return AppScreen(
      step: '07',
      center: false,
      footer: allPacked
          ? PrimaryButton(
              label: l.done,
              onPressed: () => Navigator.of(context).pushNamed('/home'),
            )
          : PrimaryButton(
              label: l.markAll,
              onPressed: () => state.markAllPacked(items),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.packTitleWithName(person.name), style: AppType.h1),
          const SizedBox(height: 16),
          PersonSelector(
            names: [
              for (final entry in state.household)
                (id: entry.id, name: entry.name),
            ],
            selectedId: person.id,
            onSelect: state.setPackPerson,
          ),
          const SizedBox(height: 18),
          Text(
            l
                .packProgress(
                  checkedUnits,
                  totalUnits,
                  formatWeight(checkedWeight),
                  formatWeight(limit),
                )
                .toUpperCase(),
            style: AppType.label.copyWith(letterSpacing: 1.2),
          ),
          if (allPacked) ...[
            const SizedBox(height: 8),
            Text(
              l.packAllDone,
              style: AppType.small.copyWith(color: AppColors.ink),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l.nextReview(formatLongDate(growth.nextReview, state.locale)),
            style: AppType.small,
          ),
          const SizedBox(height: 4),
          Text(l.expiryHint, style: AppType.small),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(l.noItems, style: AppType.body)
          else
            for (final item in items) _PackRow(item: item, state: state),
          const Hairline(),
          const SizedBox(height: 20),
          LabelText(l.communityAdvice),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _openAdvice(advice.sourceUrl),
            child: Text(
              '${advice.text(state.locale)}  ${advice.sourceLabel}',
              style: AppType.small.copyWith(color: AppColors.ink, height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Future<void> _openAdvice(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // External links are optional in the demo.
    }
  }
}

String? _beneficiaryName(AppState state, PlanItem item) {
  if (item.shared || item.beneficiaryId == item.carrierId) return null;
  for (final person in state.household) {
    if (person.id == item.beneficiaryId) return person.name;
  }
  return null;
}

class _PackRow extends StatelessWidget {
  const _PackRow({required this.item, required this.state});

  final PlanItem item;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entry = state.pack.entryFor(item.key);
    final name = item.product.name(state.locale);
    final baseName = item.quantity > 1 ? '$name ×${item.quantity}' : name;
    final beneficiary = _beneficiaryName(state, item);
    final displayName = beneficiary == null
        ? baseName
        : '$baseName · ${l.forPerson(beneficiary)}';
    final canExpire =
        item.product.category == LCategory.food ||
        item.product.category == LCategory.medication ||
        item.product.category == LCategory.water;

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => state.togglePacked(item),
              child: Row(
                children: [
                  SelectSquare(selected: entry.checked),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.input,
                        ),
                        if (entry.expiry != null)
                          Text(
                            l.expirySet(
                              formatDate(entry.expiry!, state.locale),
                            ),
                            style: AppType.label.copyWith(
                              letterSpacing: 0.4,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${formatWeight(item.weightKg)} kg',
                    style: AppType.small,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => _showItem(context, l, canExpire),
              icon: const Icon(
                Icons.more_horiz,
                size: 18,
                color: AppColors.muted,
              ),
              tooltip: l.itemDetails,
            ),
          ),
        ],
      ),
    );
  }

  void _showItem(BuildContext context, AppLocalizations l, bool canExpire) {
    showQuietSheet(
      context,
      ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final entry = state.pack.entryFor(item.key);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              LabelText(l.itemDetails),
              const SizedBox(height: 12),
              Text(
                item.product.name(state.locale),
                style: AppType.row.copyWith(fontSize: 20),
              ),
              if (_beneficiaryName(state, item) != null) ...[
                const SizedBox(height: 4),
                Text(
                  l.forPerson(_beneficiaryName(state, item)!),
                  style: AppType.small,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${formatWeight(item.weightKg)} kg · ${item.product.store.label}',
                style: AppType.small,
              ),
              if (entry.expiry != null) ...[
                const SizedBox(height: 14),
                Text(
                  l.expirySet(formatLongDate(entry.expiry!, state.locale)),
                  style: AppType.small.copyWith(color: AppColors.ink),
                ),
                Text(
                  l.expiryReminders(
                    formatDate(entry.reminder60 ?? entry.expiry!, state.locale),
                    formatDate(entry.reminder14 ?? entry.expiry!, state.locale),
                  ),
                  style: AppType.small,
                ),
              ],
              const SizedBox(height: 20),
              const Hairline(),
              CheckLine(
                selected: entry.checked,
                label: l.packed,
                onTap: () => state.togglePacked(item),
              ),
              if (canExpire)
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          entry.expiry ??
                          DateTime(now.year + 1, now.month, now.day),
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 12),
                      helpText: l.setExpiry,
                    );
                    if (picked != null) state.setExpiry(item, picked);
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.hairline),
                      ),
                    ),
                    child: Text(
                      l.setExpiry.toUpperCase(),
                      style: AppType.label.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}
