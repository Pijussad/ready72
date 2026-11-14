import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/catalogue_screen.dart';
import 'screens/checklist_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/family_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lt72_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shelter_screen.dart';
import 'screens/needs_screen.dart';
import 'screens/order_screen.dart';
import 'screens/pack_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/subscribe_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/app_state.dart';
import 'theme/design.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree');
    return scope!.notifier!;
  }
}

class Ready72App extends StatelessWidget {
  const Ready72App({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Ready72',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: Locale(state.locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: state.hasConsent && state.household.isNotEmpty
              ? '/home'
              : '/welcome',
          onGenerateRoute: (settings) {
            final page = _pageFor(settings.name);
            if (page == null) {
              return quietRoute<void>(const WelcomeScreen());
            }
            return quietRoute<void>(page);
          },
        );
      },
    );
  }

  Widget? _pageFor(String? name) {
    switch (name) {
      case '/welcome':
        return const WelcomeScreen();
      case '/home':
        return const HomeScreen();
      case '/emergency':
        return const EmergencyScreen();
      case '/checklist':
        return const ChecklistScreen();
      case '/lt72':
        return const Lt72Screen();
      case '/shelter':
        return const ShelterScreen();
      case '/settings':
        return const SettingsScreen();
      case '/catalogue':
        return const CatalogueScreen();
      case '/family':
        return const FamilyScreen();
      case '/needs':
        return const NeedsScreen();
      case '/consent':
        return const ConsentScreen();
      case '/plan':
        return const PlanScreen();
      case '/order':
        return const OrderScreen();
      case '/subscribe':
        return const SubscribeScreen();
      case '/tracking':
        return const TrackingScreen();
      case '/pack':
        return const PackScreen();
      default:
        return null;
    }
  }
}
