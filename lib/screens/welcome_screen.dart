import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../theme/design.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return AppScreen(
      showBack: false,
      trailing: LanguageToggle(
        locale: state.locale,
        onChanged: state.setLocale,
      ),
      footer: PrimaryButton(
        label: l.begin,
        onPressed: () => Navigator.of(context).pushNamed('/family'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${l.welcomeTitle1}\n${l.welcomeTitle2}',
            style: AppType.welcome,
          ),
          const SizedBox(height: 24),
          Text(l.welcomeBody, style: AppType.body),
          const SizedBox(height: 28),
          Text(l.howItWorks, style: AppType.small.copyWith(height: 1.6)),
          const SizedBox(height: 28),
          QuietLink(
            label: l.tryExample,
            textAlign: TextAlign.left,
            onTap: () async {
              await state.loadDemo();
              if (!context.mounted) return;
              await Navigator.of(context).pushNamed('/family');
            },
          ),
        ],
      ),
    );
  }
}
