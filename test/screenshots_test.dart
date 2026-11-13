@Tags(['golden'])
library;

import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ready72/app.dart';
import 'package:ready72/services/app_state.dart';
import 'package:ready72/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Light.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Inter-Medium.ttf'));
  await loader.load();

  var dir = File(Platform.resolvedExecutable).parent;
  var icons = File(
    '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  for (var i = 0; i < 8 && !icons.existsSync(); i++) {
    dir = dir.parent;
    icons = File(
      '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
  }
  if (icons.existsSync()) {
    final bytes = await icons.readAsBytes();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await iconLoader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting();
    await loadFonts();
  });

  testWidgets('capture demo screens', (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 11, 13, 12)), () async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
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

      final app = find.byType(MaterialApp);
      Future<void> shot(String name) async {
        await tester.pumpAndSettle();
        await expectLater(app, matchesGoldenFile('goldens/$name.png'));
      }

      await shot('01_welcome');

      await tester.tap(find.text('Try an example family'));
      await tester.pumpAndSettle();
      await shot('02_family');

      await tester.ensureVisible(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await shot('03_needs');

      await tester.ensureVisible(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await shot('04_consent');

      await tester.tap(find.textContaining('I agree to the processing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AGREE AND BUILD'));
      await tester.pumpAndSettle();
      await shot('05_plan');

      await tester.ensureVisible(find.textContaining('REVIEW ORDER ·'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('REVIEW ORDER ·'));
      await tester.pumpAndSettle();
      await shot('06_order');

      await tester.ensureVisible(find.text('Keep my bag fresh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep my bag fresh'));
      await tester.pumpAndSettle();
      await shot('07_subscribe');

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      await shot('08_pack');

      for (final item in [
        '45 l backpack',
        'Emergency blanket',
        'Headlamp with red light',
        'Insulin cooling pouch',
        'Medication pouch',
      ]) {
        final row = find.text(item).first;
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pump();
      }
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 2400));
      await tester.pumpAndSettle();
      await shot('09_pack_checked');

      final person = state.packPerson!;
      for (final item in state.selectedPlan!.itemsForCarrier(person.id)) {
        if (!state.pack.entryFor(item.key).checked) {
          state.togglePacked(item);
        }
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();
      await shot('10_home');

      await tester.tap(find.text('Grab and go'));
      await tester.pumpAndSettle();
      await shot('11_emergency');

      await tester.tap(find.text('Ona’s bag').first);
      await tester.pumpAndSettle();
      await shot('12_checklist');

      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Find a shelter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find a shelter'));
      await tester.pumpAndSettle();
      await shot('13_shelter');
    });
  });
}
