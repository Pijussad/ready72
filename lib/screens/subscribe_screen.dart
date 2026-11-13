import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../utils/labels.dart';
import '../widgets/common.dart';

class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final quote = state.subscriptionQuote;
    final total = formatMoney(quote.totalEur.roundToDouble(), state.locale);

    return AppScreen(
      step: '06',
      center: true,
      footer: PrimaryButton(
        label: state.subscriptionActive
            ? l.continueLabel
            : l.subscribeCta(total),
        onPressed: state.subscriptionActive
            ? () => Navigator.of(context).pushNamed('/pack')
            : () async {
                await state.subscribe();
                if (!context.mounted) return;
                await Navigator.of(context).pushNamed('/pack');
              },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l.subscribeTitle1}\n${l.subscribeTitle2}', style: AppType.h1),
          const SizedBox(height: 24),
          Text(l.subscribeBody, style: AppType.body),
          const SizedBox(height: 26),
          for (final line in quote.lines)
            Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(line.person.name, style: AppType.input),
                        Text(
                          groupLabel(l, line.person),
                          style: AppType.small,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l.perMonth(
                      formatMoney(
                        line.monthlyEur.roundToDouble(),
                        state.locale,
                      ),
                    ),
                    style: AppType.input.copyWith(
                      fontWeight: FontWeight.w300,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.total,
                    style: AppType.input.copyWith(fontSize: 18),
                  ),
                ),
                Text(l.totalPerMonth(total), style: AppType.price),
              ],
            ),
          ),
          const Hairline(),
          const SizedBox(height: 14),
          if (state.subscriptionActive) ...[
            Text(
              l.subscribed(total),
              style: AppType.small.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            QuietLink(
              label: l.cancelSubscription,
              textAlign: TextAlign.left,
              onTap: () async {
                await state.cancelSubscription();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l.subscriptionCancelled,
                      style: AppType.body.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.ink,
                  ),
                );
              },
            ),
          ] else ...[
            LabelText(l.cancelAnytime),
            const SizedBox(height: 6),
            Text(l.replacementNote, style: AppType.small),
            const SizedBox(height: 16),
            QuietLink(
              label: l.notNow,
              onTap: () => Navigator.of(context).pushNamed('/pack'),
            ),
          ],
        ],
      ),
    );
  }
}
