import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/needs.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/labels.dart';
import '../widgets/common.dart';

class NeedsScreen extends StatefulWidget {
  const NeedsScreen({super.key});

  @override
  State<NeedsScreen> createState() => _NeedsScreenState();
}

class _NeedsScreenState extends State<NeedsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _controller.text = AppScope.of(context).needsText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final hints = [
      l.hintMedication,
      l.hintAllergies,
      l.hintPets,
      l.hintBaby,
      l.hintGlasses,
    ];

    return AppScreen(
      step: '02',
      center: true,
      footer: PrimaryButton(
        label: l.continueLabel,
        onPressed: () async {
          await state.commitNeeds(_controller.text);
          if (!context.mounted) return;
          await Navigator.of(context).pushNamed('/consent');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l.needsTitle1}\n${l.needsTitle2}', style: AppType.h1),
          const SizedBox(height: 32),
          AppTextArea(
            controller: _controller,
            hint: l.needsPlaceholder,
            onChanged: (value) {
              state.previewNeeds(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Text(l.needsTrust, style: AppType.small),
          if (state.hasConsent && state.needs.byPerson.isNotEmpty) ...[
            const SizedBox(height: 18),
            LabelText(l.needsUnderstood),
            const SizedBox(height: 8),
            for (final entry in state.needs.byPerson.entries)
              if (entry.value.hasAny)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${_nameFor(state, entry.key)} · '
                    '${_needLabels(l, entry.value)}',
                    style: AppType.small.copyWith(color: AppColors.ink),
                  ),
                ),
          ],
          const SizedBox(height: 24),
          LabelText(l.youCanMention),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hint in hints)
                InkWell(
                  onTap: () {
                    final text = _controller.text.trim();
                    _controller.text = text.isEmpty
                        ? '$hint: '
                        : '$text\n$hint: ';
                    _controller.selection = TextSelection.collapsed(
                      offset: _controller.text.length,
                    );
                    state.previewNeeds(_controller.text);
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.hintBorder),
                    ),
                    child: Text(hint.toUpperCase(), style: AppType.label),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _nameFor(AppState state, String id) {
    for (final person in state.household) {
      if (person.id == id) return person.name;
    }
    return id;
  }

  String _needLabels(AppLocalizations l, PersonNeeds needs) {
    final labels = <String>[
      for (final token in <String>{
        ...needs.conditions,
        ...needs.medications,
        ...needs.allergies,
        ...needs.diets,
      })
        conditionLabel(l, token),
      if (needs.glasses) conditionLabel(l, 'glasses'),
      if (needs.mobilityAid) conditionLabel(l, 'mobility'),
      if (needs.pregnant) conditionLabel(l, 'pregnancy'),
      if (needs.diapers || needs.formula || needs.babyFood)
        conditionLabel(l, 'baby'),
    ];
    return labels.isEmpty ? l.needsNone : labels.join(' · ');
  }
}
