import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../models/plan.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../utils/labels.dart';
import '../widgets/common.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final order = state.order;

    return AppScreen(
      step: '05',
      center: false,
      footer: PrimaryButton(
        label: state.orderPlaced
            ? l.trackDelivery
            : l.placeOrder(
                order == null
                    ? formatMoney(0, state.locale)
                    : formatMoney(order.totalEur.roundToDouble(), state.locale),
              ),
        onPressed: order == null
            ? null
            : state.orderPlaced
            ? () => Navigator.of(context).pushNamed('/tracking')
            : () => state.placeOrder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.orderTitle, style: AppType.h1),
          if (order == null) ...[
            const SizedBox(height: 24),
            Text(l.planUnavailable, style: AppType.body),
          ] else ...[
            const SizedBox(height: 28),
            SectionLabel(l.stores),
            for (final storeOrder in order.storeOrders)
              _StoreRow(
                name: storeOrder.store.label,
                detail: l.itemsCount(storeOrder.itemCount),
                amount: formatMoney(storeOrder.amountEur, state.locale),
                onTap: () => _showStore(context, l, state, storeOrder, order),
              ),
            const Hairline(),
            const SizedBox(height: 24),
            SectionLabel(l.deliveries),
            if (state.orderPlaced)
              for (final shipment in order.shipments)
                _StoreRow(
                  name: shipment.store.label,
                  detail: formatDate(
                    shipment.date,
                    state.locale,
                    weekday: true,
                  ),
                  amount: statusLabel(l, shipment.status),
                  onTap: () => Navigator.of(context).pushNamed('/tracking'),
                )
            else
              _StoreRow(
                name: '${order.shipments.length} ${l.deliveries.toLowerCase()}',
                detail: formatDate(
                  order.shipments
                      .map((shipment) => shipment.date)
                      .reduce((a, b) => a.isAfter(b) ? a : b),
                  state.locale,
                  weekday: true,
                ),
                amount: '',
                onTap: () {},
              ),
            const Hairline(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.orderTotal,
                    style: AppType.input.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  formatMoney(order.totalEur.roundToDouble(), state.locale),
                  style: AppType.price,
                ),
              ],
            ),
            if (state.orderPlaced) ...[
              const SizedBox(height: 12),
              Text(
                l.orderPlaced,
                style: AppType.label.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                l.orderPlacedBody(
                  formatLongDate(
                    order.shipments
                        .map((shipment) => shipment.date)
                        .reduce((a, b) => a.isAfter(b) ? a : b),
                    state.locale,
                  ),
                ),
                style: AppType.small,
              ),
            ],
            const SizedBox(height: 18),
            QuietLink(
              label: l.keepFresh,
              onTap: () => Navigator.of(context).pushNamed('/subscribe'),
            ),
          ],
        ],
      ),
    );
  }

  void _showStore(
    BuildContext context,
    AppLocalizations l,
    AppState state,
    StoreOrder storeOrder,
    OrderData order,
  ) {
    final plan = state.selectedPlan;
    final items =
        plan == null
              ? <PlanItem>[]
              : plan.items
                    .where((item) => item.product.store == storeOrder.store)
                    .toList()
          ..sort(
            (a, b) => a.product
                .name(state.locale)
                .compareTo(b.product.name(state.locale)),
          );
    Shipment? shipment;
    for (final entry in order.shipments) {
      if (entry.store == storeOrder.store) shipment = entry;
    }

    showQuietSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LabelText(l.stores),
          const SizedBox(height: 8),
          Text(
            storeOrder.store.label,
            style: AppType.row.copyWith(fontSize: 24),
          ),
          if (shipment != null) ...[
            const SizedBox(height: 6),
            Text(
              '${formatDate(shipment.date, state.locale, weekday: true)} · '
              '${statusLabel(l, shipment.status)}',
              style: AppType.small,
            ),
          ],
          const SizedBox(height: 16),
          for (final item in items)
            _StoreItemRow(item: item, state: state, l: l),
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.total,
                    style: AppType.input.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  formatMoney(storeOrder.amountEur, state.locale),
                  style: AppType.price,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          QuietLink(
            label: l.openStore,
            textAlign: TextAlign.left,
            onTap: () async {
              final uri = Uri.tryParse(storeOrder.store.homeUrl);
              if (uri == null) return;
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          ),
          QuietLink(
            label: l.copyStoreList,
            textAlign: TextAlign.left,
            onTap: () async {
              final buffer = StringBuffer()
                ..writeln(
                  l.storeListHeader(storeOrder.store.label, items.length),
                )
                ..writeln();
              for (final item in items) {
                buffer.writeln(
                  '${item.product.name(state.locale)} ×${item.quantity} · '
                  '${formatMoney(item.priceEur, state.locale)}',
                );
              }
              await Clipboard.setData(ClipboardData(text: buffer.toString()));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l.storeListCopied,
                    style: AppType.body.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.ink,
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: l.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.name,
    required this.detail,
    required this.amount,
    this.onTap,
  });

  final String name;
  final String detail;
  final String amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(name, style: AppType.input)),
            Text(detail, maxLines: 1, softWrap: false, style: AppType.small),
            const SizedBox(width: 16),
            SizedBox(
              width: onTap == null ? 96 : 90,
              child: Text(
                amount,
                textAlign: TextAlign.right,
                maxLines: 1,
                softWrap: false,
                style: AppType.input.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoreItemRow extends StatelessWidget {
  const _StoreItemRow({
    required this.item,
    required this.state,
    required this.l,
  });

  final PlanItem item;
  final AppState state;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final name = item.product.name(state.locale);
    final subtitle = <String>[
      if (item.product.userSupplied) l.ownItem,
      if (!item.shared && item.beneficiaryId != item.carrierId)
        _beneficiary(state, item),
    ].where((value) => value.isNotEmpty).join(' · ');

    final linkable = !item.product.userSupplied;
    final targetUrl = item.product.orderUrl;
    return InkWell(
      onTap: linkable
          ? () async {
              final uri = Uri.tryParse(targetUrl);
              if (uri == null) return;
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            }
          : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.quantity > 1 ? '$name ×${item.quantity}' : name,
                    style: AppType.input,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppType.label.copyWith(
                        letterSpacing: 0.4,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.product.userSupplied
                  ? '—'
                  : formatMoney(item.priceEur, state.locale),
              style: AppType.input.copyWith(fontWeight: FontWeight.w300),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new, size: 13, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  String _beneficiary(AppState state, PlanItem item) {
    for (final person in state.household) {
      if (person.id == item.beneficiaryId) {
        return l.forPerson(person.name);
      }
    }
    return '';
  }
}
