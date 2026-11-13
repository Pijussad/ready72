import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final plan = state.selectedPlan;

    return AppScreen(
      center: false,
      footer: PrimaryButton(
        label: l.emergencyCall,
        onPressed: () => _launch(Uri.parse('tel:112')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.emergencyTitle, style: AppType.welcome),
          const SizedBox(height: 10),
          Text(l.emergencySub, style: AppType.body),
          const SizedBox(height: 26),
          if (plan == null)
            Text(l.planUnavailable, style: AppType.body)
          else ...[
            LabelText(l.emergencyTake),
            const SizedBox(height: 10),
            for (final bag in plan.bags.values)
              InkWell(
                onTap: () {
                  state.setPackPerson(bag.person.id);
                  Navigator.of(context).pushNamed('/checklist');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ink),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.packTitleWithName(bag.person.name),
                              style: AppType.option,
                            ),
                            const SizedBox(height: 3),
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
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              l.emergencyNote,
              style: AppType.small.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: 22),
            LabelText(l.emergencyHome),
            const SizedBox(height: 6),
            Text(l.emergencyHomeList, style: AppType.body),
            const SizedBox(height: 22),
            QuietLink(
              label: l.openChecklist,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/checklist'),
            ),
            const SizedBox(height: 16),
            QuietLink(
              label: l.emergencyShelter,
              textAlign: TextAlign.left,
              onTap: () => Navigator.of(context).pushNamed('/shelter'),
            ),
            const SizedBox(height: 6),
            Text(l.emergencyShelterNote, style: AppType.small),
          ],
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // The emergency screen still works without an external app.
    }
  }
}
