import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    required this.footer,
    this.step,
    this.trailing,
    this.showBack = true,
    this.center = true,
    this.showSettings = true,
  });

  final Widget child;
  final Widget footer;
  final String? step;
  final Widget? trailing;
  final bool showBack;
  final bool showSettings;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppHeader(
                                  step: step,
                                  trailing: trailing,
                                  showBack: showBack,
                                  showSettings: showSettings,
                                ),
                                if (step case final value?)
                                  AppProgress(step: value),
                                Expanded(
                                  child: Align(
                                    alignment: center
                                        ? Alignment.center
                                        : Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: child,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  color: AppColors.white,
                  padding: EdgeInsets.fromLTRB(28, 8, 28, 20 + bottomInset),
                  child: footer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppProgress extends StatelessWidget {
  const AppProgress({super.key, required this.step});

  final String step;

  @override
  Widget build(BuildContext context) {
    final value = (int.tryParse(step) ?? 0) / 7;
    if (value <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 1,
        child: Row(
          children: [
            Expanded(
              flex: (value * 1000).round(),
              child: const ColoredBox(color: AppColors.ink),
            ),
            Expanded(
              flex: ((1 - value) * 1000).round(),
              child: const ColoredBox(color: AppColors.hairline),
            ),
          ],
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.step,
    this.trailing,
    this.showBack = true,
    this.showSettings = true,
  });

  final String? step;
  final Widget? trailing;
  final bool showBack;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return Row(
      children: [
        if (canPop) ...[
          Semantics(
            button: true,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.chevron_left, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        const Text('READY72', style: AppType.header),
        const Spacer(),
        ?trailing,
        if (showSettings)
          Semantics(
            button: true,
            label: MaterialLocalizations.of(context).moreButtonTooltip,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/settings'),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.more_horiz, size: 20, color: AppColors.muted),
              ),
            ),
          ),
        if (step != null && trailing == null)
          SizedBox(
            width: 30,
            child: Text(
              step!,
              textAlign: TextAlign.right,
              style: AppType.header.copyWith(color: AppColors.muted),
            ),
          ),
      ],
    );
  }
}

class Hairline extends StatelessWidget {
  const Hairline({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color ?? AppColors.hairline);
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 52,
        color: enabled ? AppColors.ink : AppColors.disabledFill,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return enabled ? Colors.white24 : Colors.black12;
              }
              return Colors.transparent;
            }),
            child: Center(
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppType.button.copyWith(
                  color: enabled ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuietLink extends StatelessWidget {
  const QuietLink({
    super.key,
    required this.label,
    this.onTap,
    this.textAlign = TextAlign.center,
  });

  final String label;
  final VoidCallback? onTap;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Align(
            alignment: textAlign == TextAlign.left
                ? Alignment.centerLeft
                : Alignment.center,
            child: Text(
              label,
              textAlign: textAlign,
              style: AppType.label.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.muted,
                decorationThickness: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  const LabelText(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppType.label.copyWith(color: color),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.onChanged,
    this.semanticLabel,
    this.inputFormatters,
    this.autofocus = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: textAlign,
        maxLines: maxLines,
        autofocus: autofocus,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        style: AppType.input,
        cursorColor: AppColors.ink,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: AppType.input.copyWith(color: AppColors.muted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ink, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: TextField(
          controller: controller,
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          onChanged: onChanged,
          style: AppType.input.copyWith(height: 23 / 15),
          cursorColor: AppColors.ink,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: AppType.input.copyWith(
              height: 23 / 15,
              color: AppColors.muted,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class SelectSquare extends StatelessWidget {
  const SelectSquare({
    super.key,
    required this.selected,
    this.size = 12,
    this.disabled = false,
  });

  final bool selected;
  final double size;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected && !disabled ? AppColors.ink : AppColors.white,
        border: Border.all(
          color: disabled ? AppColors.hairline : AppColors.ink,
          width: 1,
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.bottom = 8});

  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: LabelText(text),
    );
  }
}

class CheckLine extends StatelessWidget {
  const CheckLine({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      checked: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SelectSquare(selected: selected, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    label,
                    style: AppType.input.copyWith(height: 20 / 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonSelector extends StatelessWidget {
  const PersonSelector({
    super.key,
    required this.names,
    required this.selectedId,
    required this.onSelect,
  });

  final List<({String id, String name})> names;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 2,
      children: [
        for (final entry in names)
          Semantics(
            button: true,
            selected: entry.id == selectedId,
            label: entry.name,
            child: InkWell(
              onTap: () => onSelect(entry.id),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.id == selectedId) ...[
                      const SelectSquare(selected: true, size: 7),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      entry.name,
                      style: AppType.label.copyWith(
                        color: entry.id == selectedId
                            ? AppColors.ink
                            : AppColors.muted,
                        fontWeight: entry.id == selectedId
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.locale,
    required this.onChanged,
  });

  final String locale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(String code, String label) {
      final selected = locale == code;
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () => onChanged(code),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: AppType.header.copyWith(
                color: selected ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item('en', 'EN'),
        Text('/', style: AppType.header.copyWith(color: AppColors.hairline)),
        item('lt', 'LT'),
      ],
    );
  }
}

Future<T?> showQuietSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.white,
    barrierColor: Colors.black26,
    isScrollControlled: true,
    elevation: 0,
    shape: const RoundedRectangleBorder(),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            28,
            20,
            28,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(child: child),
        ),
      );
    },
  );
}
