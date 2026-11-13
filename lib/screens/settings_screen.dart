import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../theme/design.dart';
import '../widgets/common.dart';
import '../widgets/privacy_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return AppScreen(
      showSettings: false,
      center: false,
      footer: PrimaryButton(
        label: l.close,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.settingsTitle, style: AppType.h1),
          const SizedBox(height: 28),
          LabelText(l.languageLabel),
          const SizedBox(height: 6),
          LanguageToggle(locale: state.locale, onChanged: state.setLocale),
          const SizedBox(height: 20),
          const Hairline(),
          QuietLink(
            label: l.settingsPrivacy,
            textAlign: TextAlign.left,
            onTap: () => showPrivacySheet(context, state),
          ),
          const SizedBox(height: 16),
          LabelText(l.aboutPrototype),
          const SizedBox(height: 6),
          Text(l.aboutPrototypeBody, style: AppType.small),
        ],
      ),
    );
  }
}
