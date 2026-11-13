import 'plan.dart';
import 'product.dart';

enum ShipmentStatus { ordered, packed, onTheWay, delivered }

class StoreOrder {
  const StoreOrder({
    required this.store,
    required this.itemCount,
    required this.amountEur,
  });

  final Store store;
  final int itemCount;
  final double amountEur;
}

class Shipment {
  const Shipment({
    required this.store,
    required this.date,
    required this.status,
    required this.itemCount,
  });

  final Store store;
  final DateTime date;
  final ShipmentStatus status;
  final int itemCount;
}

class OrderData {
  const OrderData({
    required this.storeOrders,
    required this.shipments,
    required this.totalEur,
    required this.unverifiedPriceCount,
    required this.createdAt,
  });

  final List<StoreOrder> storeOrders;
  final List<Shipment> shipments;
  final double totalEur;
  final int unverifiedPriceCount;
  final DateTime createdAt;

  int get itemCount =>
      storeOrders.fold(0, (sum, order) => sum + order.itemCount);
}

class OrderSplitter {
  OrderSplitter._();

  static OrderData fromPlan(PlanResult plan, {DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    final grouped = <Store, List<PlanItem>>{};
    for (final item in plan.items) {
      grouped.putIfAbsent(item.product.store, () => []).add(item);
    }

    // Fixed store routing, not a line-count sort: every order always presents
    // the same store order and the same store assignment from the catalogue.
    final stores = [
      for (final store in Store.values)
        if (grouped.containsKey(store)) store,
    ];

    final orders = <StoreOrder>[];
    final shipments = <Shipment>[];
    for (var index = 0; index < stores.length; index++) {
      final store = stores[index];
      final items = grouped[store]!;
      final amount = items.fold(0.0, (sum, item) => sum + item.priceEur);
      final units = items.fold(0, (sum, item) => sum + item.quantity);
      orders.add(StoreOrder(store: store, itemCount: units, amountEur: amount));
      shipments.add(
        Shipment(
          store: store,
          date: createdAt.add(Duration(days: store.deliveryDays)),
          status: _statusFor(store),
          itemCount: units,
        ),
      );
    }

    return OrderData(
      storeOrders: orders,
      shipments: shipments,
      totalEur: plan.totalPrice,
      unverifiedPriceCount: plan.unverifiedPriceCount,
      createdAt: createdAt,
    );
  }

  /// Statuses are simulated and tied to the store, not to list position.
  static ShipmentStatus _statusFor(Store store) {
    switch (store) {
      case Store.barbora:
        return ShipmentStatus.onTheWay;
      case Store.rimi:
        return ShipmentStatus.packed;
      case Store.eurovaistine:
      case Store.decathlon:
        return ShipmentStatus.ordered;
    }
  }
}
