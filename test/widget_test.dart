import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ready72/app.dart';
import 'package:ready72/services/app_state.dart';
import 'package:ready72/models/person.dart';
import 'package:ready72/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('demo path: welcome to pack', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final state = AppState(storage);
    await state.init();

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: Ready72App(state: state),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Be ready.'), findsOneWidget);

    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Who are you'), findsOneWidget);

    final people = [
      ('Jonas', '34', '82'),
      ('Rūta', '32', '64'),
      ('Mia', '2', '13'),
      ('Ona', '71', '62'),
    ];
    for (var i = 0; i < people.length; i++) {
      final row = people[i];
      var fields = find.byType(TextField);
      await tester.enterText(fields.at(i * 3), row.$1);
      await tester.pump();
      fields = find.byType(TextField);
      await tester.enterText(fields.at(i * 3 + 1), row.$2);
      await tester.enterText(fields.at(i * 3 + 2), row.$3);
      await tester.pump();
    }
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tell us what'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      DemoHousehold.needsText,
    );
    await tester.pump();
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Before we'), findsOneWidget);

    // The button is disabled until the required consent box is checked.
    await tester.tap(find.text('AGREE AND BUILD'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(state.hasConsent, isFalse);
    expect(find.textContaining('Before we'), findsOneWidget);

    await tester.tap(find.textContaining('I agree to the processing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AGREE AND BUILD'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Choose'), findsOneWidget);
    expect(find.text('Comfort'), findsOneWidget);

    await tester.ensureVisible(find.textContaining('REVIEW ORDER ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('REVIEW ORDER ·'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your order'), findsOneWidget);
    expect(find.text('Barbora'), findsWidgets);
    expect(find.text('Decathlon'), findsWidgets);

    // Store details: what is ordered from that store.
    await tester.ensureVisible(find.text('Barbora').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbora').first);
    await tester.pumpAndSettle();
    expect(find.text('STORES'), findsWidgets);
    await tester.ensureVisible(find.text('CLOSE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    // Place the order, then open the tracking timeline.
    await tester.ensureVisible(find.textContaining('PLACE ORDER ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('PLACE ORDER ·'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Order placed'), findsOneWidget);
    await tester.tap(find.text('TRACK DELIVERY'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Order tracking'), findsOneWidget);
    expect(find.textContaining('TRACKING CODE'), findsWidgets);
    await tester.ensureVisible(find.text('BACK TO ORDER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BACK TO ORDER'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your order'), findsOneWidget);

    await tester.ensureVisible(find.text('Keep my bag fresh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep my bag fresh'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Keep your'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.textContaining('€16 / month'), findsWidgets);

    await tester.ensureVisible(find.textContaining('SUBSCRIBE'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('SUBSCRIBE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ona'), findsWidgets);
    expect(find.text('MARK ALL PACKED'), findsOneWidget);
    expect(state.subscriptionActive, isTrue);

    await tester.tap(find.text('MARK ALL PACKED'));
    await tester.pumpAndSettle();
    expect(find.text('DONE'), findsOneWidget);
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your bags'), findsOneWidget);

    await tester.tap(find.text('Grab and go'));
    await tester.pumpAndSettle();
    expect(find.textContaining('If you have to leave now'), findsOneWidget);
    expect(find.text('CALL 112'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open printable checklist'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Copy it'), findsOneWidget);
    await tester.tap(find.text('Copy checklist'));
    await tester.pump();
    expect(find.text('Checklist'), findsOneWidget);
  });
}
