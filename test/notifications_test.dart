import 'package:flutter_test/flutter_test.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/services/app_state.dart';
import 'package:ready72/services/notifications.dart';
import 'package:ready72/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpyNotifications extends NotificationService {
  final scheduled = <DateTime>[];
  var permissions = 0;
  var cancelled = 0;

  @override
  Future<void> requestPermissions() async => permissions++;

  @override
  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    scheduled.add(when);
  }

  @override
  Future<void> cancelAll() async => cancelled++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reminders are scheduled only after consent and on expiry', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final spy = SpyNotifications();
    final state = AppState(storage, notifications: spy);
    await state.init();
    await state.setHousehold(DemoHousehold.people);
    state.previewNeeds(DemoHousehold.needsText);

    expect(spy.permissions, 0);
    expect(spy.scheduled, isEmpty);

    await state.agreeAndSend(reminders: true);
    expect(spy.permissions, 1);
    expect(spy.scheduled.length, DemoHousehold.people.length);

    final item = state.selectedPlan!.items.first;
    final expiry = DateTime.now().add(const Duration(days: 120));
    state.setExpiry(item, expiry);
    expect(spy.scheduled.length, greaterThan(DemoHousehold.people.length));

    await state.deleteAll();
    expect(spy.cancelled, 1);
  });

  test('no reminders are scheduled when the box is off', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final spy = SpyNotifications();
    final state = AppState(storage, notifications: spy);
    await state.init();
    await state.setHousehold(DemoHousehold.people);
    await state.agreeAndSend(reminders: false);
    expect(spy.permissions, 0);
    expect(spy.scheduled, isEmpty);
  });
}
