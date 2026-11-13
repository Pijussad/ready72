import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../data/lt72.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../utils/labels.dart';
import '../widgets/common.dart';

class Lt72Screen extends StatelessWidget {
  const Lt72Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final plan = state.selectedPlan;
    final locale = Localizations.localeOf(context).languageCode;
    final items = [...lt72Items]
      ..sort((a, b) {
        final byCategory = a.category.index.compareTo(b.category.index);
        if (byCategory != 0) return byCategory;
        return a.name(locale).compareTo(b.name(locale));
      });

    final statuses = {
      for (final item in items) item.id: _status(item, plan?.coveredCategories),
    };
    final covered = statuses.values
        .where((value) => value == _Lt72Status.covered)
        .length;
    final home = statuses.values
        .where((value) => value == _Lt72Status.fromHome)
        .length;
    final gaps = statuses.length - covered - home;

    return AppScreen(
      center: false,
      footer: PrimaryButton(
        label: l.close,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.lt72List, style: AppType.h1),
          const SizedBox(height: 8),
          Text(l.lt72ListSub, style: AppType.body),
          const SizedBox(height: 14),
          Text(
            '${items.length} · ${formatWeight(items.fold(0.0, (sum, item) => sum + item.weightKg))} kg',
            style: AppType.label,
          ),
          const SizedBox(height: 6),
          Text(l.lt72Summary(covered, home, gaps), style: AppType.label),
          const SizedBox(height: 6),
          Text(l.lt72MappingNote, style: AppType.small),
          const SizedBox(height: 10),
          for (final item in items)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name(locale), style: AppType.input),
                        const SizedBox(height: 3),
                        Text(
                          '${item.quantity} · ${formatWeight(item.weightKg)} kg · '
                          '${categoryLabel(l, item.category)}'
                          '${item.supplementary ? ' · ${l.lt72Supplementary}' : ''}'
                          '${item.conditional != null ? ' · ${l.lt72Conditional}' : ''}',
                          style: AppType.small,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _statusLabel(l, statuses[item.id]!),
                        style: AppType.label.copyWith(letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _priorityLabel(l, item.priority),
                        style: AppType.small,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          QuietLink(
            label: l.lt72OpenSource,
            textAlign: TextAlign.left,
            onTap: () async {
              final uri = Uri.tryParse(Lt72Item.sourceUrl);
              if (uri == null) return;
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }

  _Lt72Status _status(Lt72Item item, Set<LCategory>? covered) {
    const fromHomeIds = {
      'aid-meds',
      'aid-history',
      'aid-glasses',
      'aid-tourniquet',
      'aid-mask',
      'aid-iodide',
      'aid-gloves',
      'elec-charger',
    };
    if (item.id.startsWith('doc-') ||
        item.id.startsWith('cloth-') ||
        item.id.startsWith('rest-') ||
        item.id.startsWith('tool-') ||
        fromHomeIds.contains(item.id)) {
      return _Lt72Status.fromHome;
    }
    if (item.id == 'elec-solar') return _Lt72Status.gap;
    if (covered != null && covered.contains(item.category)) {
      return _Lt72Status.covered;
    }
    return item.conditional != null ? _Lt72Status.fromHome : _Lt72Status.gap;
  }

  String _statusLabel(AppLocalizations l, _Lt72Status status) {
    switch (status) {
      case _Lt72Status.covered:
        return l.lt72Covered;
      case _Lt72Status.fromHome:
        return l.lt72FromHome;
      case _Lt72Status.gap:
        return l.lt72Gap;
    }
  }

  String _priorityLabel(AppLocalizations l, Priority priority) {
    switch (priority) {
      case Priority.critical:
        return l.lt72Critical;
      case Priority.important:
        return l.lt72Important;
      case Priority.comfort:
        return l.lt72Comfort;
    }
  }
}

enum _Lt72Status { covered, fromHome, gap }
