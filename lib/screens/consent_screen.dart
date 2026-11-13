import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/privacy_sheet.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _required = false;
  bool _reminders = false;
  bool _busy = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final state = AppScope.of(context);
    _required = state.hasConsent;
    _reminders = state.reminders;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    return AppScreen(
      step: '03',
      center: true,
      footer: PrimaryButton(
        label: state.hasConsent ? l.continueLabel : l.agreeAndSend,
        onPressed: _required && !_busy ? () => _submit(state) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l.consentTitle1}\n${l.consentTitle2}', style: AppType.h1),
          const SizedBox(height: 24),
          Text(l.consentBody, style: AppType.body),
          if (state.consent != null) ...[
            const SizedBox(height: 14),
            Text(
              l.consentRecorded(
                formatLongDate(state.consent!.grantedAt, state.locale),
              ),
              style: AppType.small.copyWith(color: AppColors.ink),
            ),
          ],
          const SizedBox(height: 26),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.hairline)),
            ),
            child: CheckLine(
              selected: _required,
              label: l.consentRequired,
              onTap: () => setState(() => _required = !_required),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.hairline)),
            ),
            child: CheckLine(
              selected: _reminders,
              label: l.consentReminders,
              onTap: () => setState(() => _reminders = !_reminders),
            ),
          ),
          const Hairline(),
          const SizedBox(height: 18),
          QuietLink(
            label: l.privacyNotice,
            textAlign: TextAlign.left,
            onTap: () => showPrivacySheet(context, state),
          ),
          const SizedBox(height: 2),
          Text(l.consentGateHint, style: AppType.small),
          if (_busy) ...[
            const SizedBox(height: 12),
            Text(l.buildingPlan, style: AppType.small),
          ],
        ],
      ),
    );
  }

  Future<void> _submit(AppState state) async {
    if (state.hasConsent) {
      await Navigator.of(context).pushNamed('/plan');
      return;
    }
    setState(() => _busy = true);
    await state.agreeAndSend(reminders: _reminders);
    if (!mounted) return;
    setState(() => _busy = false);
    await Navigator.of(context).pushNamed('/plan');
  }
}
