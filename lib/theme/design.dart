import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF6B6B6B);
  static const Color hairline = Color(0xFFE4E4E4);
  static const Color hintBorder = Color(0xFFD0D0D0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color disabledFill = Color(0xFFE4E4E4);
}

class AppType {
  AppType._();

  static const String family = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontFamily: family,
    fontSize: 38,
    height: 42 / 38,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.14,
    color: AppColors.ink,
  );

  static const TextStyle welcome = TextStyle(
    fontFamily: family,
    fontSize: 42,
    height: 46 / 42,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.26,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const TextStyle row = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w300,
    color: AppColors.ink,
  );

  static const TextStyle input = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w300,
    color: AppColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.muted,
  );

  static const TextStyle header = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.32,
    color: AppColors.ink,
  );

  static const TextStyle small = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.32,
    color: Colors.white,
  );

  static const TextStyle price = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w300,
    color: AppColors.ink,
  );

  static const TextStyle option = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppType.family,
    scaffoldBackgroundColor: AppColors.white,
    canvasColor: AppColors.white,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: const Color(0x11111111),
    colorScheme: const ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.ink,
      selectionColor: Color(0x22111111),
      selectionHandleColor: AppColors.ink,
    ),
    dividerColor: AppColors.hairline,
    iconTheme: const IconThemeData(color: AppColors.ink),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(
        fontFamily: AppType.family,
        fontSize: 14,
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.fixed,
      elevation: 0,
      shape: RoundedRectangleBorder(),
    ),
  );
}

Route<T> quietRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
