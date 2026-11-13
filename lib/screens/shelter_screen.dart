import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/design.dart';
import '../widgets/common.dart';

class ShelterScreen extends StatelessWidget {
  const ShelterScreen({super.key});

  static const String _official =
      'https://pagd.lrv.lt/lt/veiklos-sritys/civiline-sauga/civiline-sauga-gyventojams/kolektyvines-apsaugos-statiniai/';
  static const String _map =
      'https://www.google.com/maps/search/?api=1&query=kolektyvin%C4%97s%20apsaugos%20statinys%20near%20me';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScreen(
      center: false,
      footer: PrimaryButton(
        label: l.emergencyCall,
        onPressed: () => _launch('tel:112'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.shelterTitle, style: AppType.h1),
          const SizedBox(height: 8),
          Text(l.shelterSub, style: AppType.body),
          const SizedBox(height: 26),
          _ActionCard(
            title: l.shelterOfficial,
            subtitle: 'pagd.lrv.lt',
            onTap: () => _launch(_official),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: l.shelterMap,
            subtitle: 'Google Maps',
            onTap: () => _launch(_map),
          ),
          const SizedBox(height: 18),
          Text(l.shelterNote, style: AppType.small),
          const SizedBox(height: 18),
          Text(
            l.shelterCall,
            style: AppType.small.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.ink)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppType.option),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppType.small),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}
