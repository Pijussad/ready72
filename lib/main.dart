import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/app_state.dart';
import 'services/notifications.dart';
import 'services/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final storage = await StorageService.create();
  final notifications = NotificationService();
  await notifications.init();
  final state = AppState(storage, notifications: notifications);
  await state.init();
  runApp(
    AppScope(
      state: state,
      child: Ready72App(state: state),
    ),
  );
}
