import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ready72/app.dart';
import 'package:ready72/services/app_state.dart';
import 'package:ready72/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _pumpApp(WidgetTester tester) async {
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
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('missing weight blocks the family step', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();

    var fields = find.byType(TextField);
    expect(fields, findsWidgets);
    await tester.enterText(fields.at(0), 'Test');
    await tester.pump();
    fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '30');
    await tester.pump();
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('Weight must be between 2 and 300 kg.'), findsOneWidget);
    expect(find.textContaining('Who are you'), findsOneWidget);
  });

  testWidgets('invalid age blocks the family step', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();

    var fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Test');
    await tester.pump();
    fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '140');
    await tester.enterText(fields.at(2), '70');
    await tester.pump();
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('Age must be between 0 and 120.'), findsOneWidget);
    expect(find.textContaining('Who are you'), findsOneWidget);
  });

  testWidgets('language switch changes the welcome copy', (tester) async {
    final state = await _pumpApp(tester);
    await tester.tap(find.text('LT'));
    await tester.pumpAndSettle();

    expect(state.locale, 'lt');
    expect(find.textContaining('Pasiruoškite.'), findsOneWidget);
    expect(find.textContaining('Be ready.'), findsNothing);
  });
}
