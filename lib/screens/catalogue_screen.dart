import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../data/store_catalogue.dart';
import '../l10n/app_localizations.dart';
import '../theme/design.dart';
import '../widgets/common.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final _controller = TextEditingController();
  StoreCatalogue? _catalogue;
  String _query = '';
  String _store = '';
  List<StoreOffer> _results = const [];
  bool _loading = true;
  bool _aiBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final catalogue = await StoreCatalogue.load();
      if (!mounted) return;
      setState(() {
        _catalogue = catalogue;
        _loading = false;
      });
      _search('');
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _search(String query) {
    final catalogue = _catalogue;
    if (catalogue == null) return;
    setState(() {
      _query = query;
      _results = catalogue.search(
        query,
        stores: _store.isEmpty ? const {} : {_store},
        limit: 30,
      );
    });
  }

  Future<void> _askAi() async {
    final state = AppScope.of(context);
    if (_query.trim().isEmpty || _results.isEmpty) return;
    setState(() => _aiBusy = true);
    final picks = await state.aiCataloguePicks(_query, _results);
    if (!mounted) return;
    setState(() {
      _aiBusy = false;
      if (picks.isNotEmpty) _results = picks;
    });
    if (picks.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).catalogueAiEmpty)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final catalogue = _catalogue;
    return AppScreen(
      center: false,
      showSettings: false,
      footer: PrimaryButton(
        label: l.close,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.catalogueTitle, style: AppType.h1),
          const SizedBox(height: 8),
          Text(l.catalogueBody, style: AppType.small),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: AppType.input,
            decoration: InputDecoration(hintText: l.catalogueSearchHint),
            onChanged: _search,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StoreChip(
                label: l.catalogueAll,
                selected: _store.isEmpty,
                onTap: () {
                  _store = '';
                  _search(_query);
                },
              ),
              for (final store in const [
                'barbora',
                'decathlon',
                'eurovaistine',
              ])
                _StoreChip(
                  label: _storeLabel(store),
                  selected: _store == store,
                  onTap: () {
                    _store = store;
                    _search(_query);
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (catalogue == null)
            Text(l.catalogueNoResults, style: AppType.small)
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.catalogueCount(catalogue.offers.length),
                    style: AppType.small,
                  ),
                ),
                if (state.aiConfigured && _query.trim().isNotEmpty)
                  QuietLink(
                    label: _aiBusy ? '…' : l.catalogueAiPick,
                    onTap: _aiBusy ? () {} : _askAi,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(l.catalogueNoResults, style: AppType.small),
              ),
            for (final offer in _results) _OfferRow(offer: offer),
          ],
        ],
      ),
    );
  }

  String _storeLabel(String store) {
    switch (store) {
      case 'barbora':
        return 'Barbora';
      case 'decathlon':
        return 'Decathlon';
      case 'eurovaistine':
        return 'Eurovaistinė';
      default:
        return store;
    }
  }
}

class _StoreChip extends StatelessWidget {
  const _StoreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.hairline,
          ),
          color: selected ? AppColors.ink : AppColors.white,
        ),
        child: Text(
          label,
          style: AppType.small.copyWith(
            color: selected ? AppColors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer});

  final StoreOffer offer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(offer.url);
        if (uri == null) return;
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                  Text(offer.name, style: AppType.input.copyWith(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    [
                      offer.storeLabel,
                      if (offer.pack.isNotEmpty) offer.pack,
                      offer.role,
                    ].join(' · '),
                    style: AppType.small,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('€${offer.priceEur.toStringAsFixed(2)}', style: AppType.price),
          ],
        ),
      ),
    );
  }
}
