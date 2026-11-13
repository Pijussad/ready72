import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../utils/labels.dart';
import '../widgets/common.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final order = state.order;

    return AppScreen(
      step: '05',
      center: false,
      footer: PrimaryButton(
        label: l.backToOrder,
        onPressed: () => Navigator.of(context).pushNamed('/order'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.trackingTitle, style: AppType.h1),
          const SizedBox(height: 18),
          if (order == null)
            Text(l.planUnavailable, style: AppType.body)
          else
            for (final shipment in order.shipments)
              _ShipmentBlock(shipment: shipment, locale: state.locale, l: l),
          const SizedBox(height: 20),
          Text(l.orderTotal, style: AppType.small),
        ],
      ),
    );
  }
}

class _ShipmentBlock extends StatelessWidget {
  const _ShipmentBlock({
    required this.shipment,
    required this.locale,
    required this.l,
  });

  final Shipment shipment;
  final String locale;
  final AppLocalizations l;

  String _storeCode(Store store) {
    switch (store) {
      case Store.barbora:
        return 'BAR';
      case Store.rimi:
        return 'RIM';
      case Store.eurovaistine:
        return 'EVA';
      case Store.decathlon:
        return 'DEC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = shipment.status.index;
    final code =
        'R72-${_storeCode(shipment.store)}-'
        '${shipment.date.month}${shipment.date.day}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shipment.store.label,
                  style: AppType.input.copyWith(fontSize: 17),
                ),
              ),
              Text(
                statusLabel(l, shipment.status),
                style: AppType.small.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(formatLongDate(shipment.date, locale), style: AppType.small),
          const SizedBox(height: 4),
          LabelText(l.trackingCode(code)),
          const SizedBox(height: 12),
          for (var i = 0; i < ShipmentStatus.values.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SelectSquare(
                    selected: i <= current,
                    size: 8,
                    disabled: i > current,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusLabel(l, ShipmentStatus.values[i]),
                    style: AppType.small.copyWith(
                      color: i <= current ? AppColors.ink : AppColors.muted,
                      fontWeight: i == current
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
