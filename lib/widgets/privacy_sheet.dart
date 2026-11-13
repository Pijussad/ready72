import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import 'common.dart';

void showPrivacySheet(BuildContext context, AppState state) {
  showQuietSheet(
    context,
    ListenableBuilder(
      listenable: state,
      builder: (context, _) => _PrivacyBody(state: state),
    ),
  );
}

class _PrivacyBody extends StatelessWidget {
  const _PrivacyBody({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelText(l.privacyTitle),
        const SizedBox(height: 16),
        Text(l.privacyBody, style: AppType.body.copyWith(height: 1.5)),
        if (state.consent != null) ...[
          const SizedBox(height: 16),
          Text(
            l.consentRecorded(
              formatLongDate(state.consent!.grantedAt, state.locale),
            ),
            style: AppType.small.copyWith(color: AppColors.ink),
          ),
        ],
        const SizedBox(height: 24),
        const Hairline(),
        _Action(
          label: l.exportData,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: state.exportData()));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l.dataCopied,
                  style: AppType.body.copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.ink,
              ),
            );
          },
        ),
        if (state.household.isNotEmpty)
          _Action(
            label: state.hasConsent ? l.withdrawConsent : l.delete,
            onTap: () => _confirmDelete(context),
          ),
        const SizedBox(height: 16),
        LanguageToggle(locale: state.locale, onChanged: state.setLocale),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
        );
      },
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await state.deleteAll();
    navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppType.label.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.muted,
          ),
        ),
      ),
    );
  }
}
