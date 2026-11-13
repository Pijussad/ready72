import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ready72/models/needs.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/services/app_state.dart';
import 'package:ready72/services/consent.dart';
import 'package:ready72/services/deepseek_client.dart';
import 'package:ready72/services/storage.dart';

class SpyClient extends DeepSeekClient {
  int calls = 0;

  @override
  bool get enabled => true;

  @override
  Future<ParsedNeeds?> extractNeeds({
    required String text,
    required List<Person> household,
    required ConsentRecord? consent,
  }) async {
    calls++;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('no AI call and no stored health text before consent', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final spy = SpyClient();
    final state = AppState(storage, ai: spy);
    await state.init();

    state.previewNeeds('Ona has diabetes and takes insulin.');
    await state.setHousehold(DemoHousehold.people);
    expect(spy.calls, 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isNot(contains('ready72.snapshot.v1')));
    expect(prefs.getKeys(), isNot(contains('ready72.snapshot.v2')));

    expect(state.needs.byPerson, isEmpty);
    await state.agreeAndSend(reminders: true);
    // The deterministic parser runs on-device. The AI client has no 'ai'
    // consent purpose in this build, so it is not called.
    expect(spy.calls, 0);
    expect(state.needs.byPerson, isNotEmpty);
    expect(state.hasConsent, isTrue);
    expect(state.reminders, isTrue);

    final loaded = storage.load();
    expect(loaded, isNotNull);
    expect(loaded!.consent, isNotNull);
    expect(loaded.needsText, contains('diabetes'));
  });

  test('the client refuses to run without a consent record', () async {
    final client = DeepSeekClient();
    expect(
      () => client.extractNeeds(
        text: 'anything',
        household: const [],
        consent: null,
      ),
      throwsA(isA<ConsentRequiredException>()),
    );
  });

  test('withdraw and delete removes everything from the device', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final state = AppState(storage, ai: SpyClient());
    await state.init();
    await state.agreeAndSend(reminders: true);
    expect(state.hasConsent, isTrue);

    await state.deleteAll();
    expect(state.household, isEmpty);
    expect(state.hasConsent, isFalse);

    final restarted = AppState(storage);
    await restarted.init();
    expect(restarted.household, isEmpty);
    expect(restarted.hasConsent, isFalse);
  });
}
