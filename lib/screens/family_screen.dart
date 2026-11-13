import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/person.dart';
import '../theme/design.dart';
import '../widgets/common.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final List<_Draft> _rows = [];
  bool _initialized = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final state = AppScope.of(context);
    for (final person in state.household) {
      _rows.add(_Draft.fromPerson(person));
    }
    _rows.add(_Draft.empty());
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScreen(
      step: '01',
      center: true,
      footer: PrimaryButton(
        label: l.continueLabel,
        onPressed: () => _submit(l),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${l.familyTitle1}\n${l.familyTitle2}', style: AppType.h1),
          const SizedBox(height: 32),
          _headerRow(l: l),
          for (var index = 0; index < _rows.length; index++)
            _buildRow(index, l),
          const Hairline(),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: AppType.small.copyWith(color: AppColors.ink),
              ),
            ),
          ],
          const SizedBox(height: 10),
          QuietLink(
            label: l.addPerson,
            textAlign: TextAlign.left,
            onTap: () {
              if (_rows.isNotEmpty && _rows.last.isEmpty) return;
              setState(() => _rows.add(_Draft.empty()));
            },
          ),
          const SizedBox(height: 8),
          Text(l.familyHelper, style: AppType.small),
        ],
      ),
    );
  }

  Widget _headerRow({required AppLocalizations l}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: LabelText(l.nameLabel)),
          const SizedBox(width: 6),
          SizedBox(width: 52, child: LabelText(l.ageLabel)),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: LabelText(l.weightLabel),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildRow(int index, AppLocalizations l) {
    final row = _rows[index];
    final isLast = index == _rows.length - 1;
    final empty = row.isEmpty;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppTextField(
              controller: row.name,
              hint: l.namePlaceholder,
              semanticLabel: l.nameLabel,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _onLastChanged(isLast),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 52,
            child: AppTextField(
              controller: row.age,
              hint: l.agePlaceholder,
              semanticLabel: l.ageLabel,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              textInputAction: TextInputAction.next,
              onChanged: (_) => _onLastChanged(isLast),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
            child: AppTextField(
              controller: row.weight,
              hint: l.weightPlaceholder,
              semanticLabel: l.weightLabel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _onLastChanged(isLast),
            ),
          ),
          SizedBox(
            width: 44,
            child: empty
                ? const SizedBox.shrink()
                : Semantics(
                    button: true,
                    label: l.removeNamed(row.name.text),
                    child: InkWell(
                      onTap: () => _remove(index),
                      child: const SizedBox(
                        height: 44,
                        child: Center(
                          child: Text(
                            '×',
                            style: TextStyle(
                              fontFamily: AppType.family,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _onLastChanged(bool wasLast) {
    if (_error != null) setState(() => _error = null);
    if (!wasLast) return;
    final last = _rows.last;
    if (!last.isEmpty) {
      setState(() => _rows.add(_Draft.empty()));
    }
  }

  void _remove(int index) {
    if (index < 0 || index >= _rows.length) return;
    final row = _rows[index];
    if (row.isEmpty) return;
    setState(() {
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_Draft.empty());
      _error = null;
    });
    row.dispose();
  }

  Future<void> _submit(AppLocalizations l) async {
    final people = <Person>[];
    for (var index = 0; index < _rows.length; index++) {
      final row = _rows[index];
      if (row.isEmpty) continue;
      final name = row.name.text.trim();
      final ageText = row.age.text.trim();
      final weightText = row.weight.text.trim().replaceAll(',', '.');

      if (name.isEmpty) {
        setState(() => _error = l.nameRequired);
        return;
      }
      final age = int.tryParse(ageText);
      if (age == null || age < 0 || age > 120) {
        setState(() => _error = l.ageInvalid);
        return;
      }
      final weight = double.tryParse(weightText);
      if (weight == null || weight < 2 || weight > 300) {
        setState(() => _error = l.weightInvalid);
        return;
      }
      people.add(
        Person(
          id: row.id ?? 'p-${DateTime.now().microsecondsSinceEpoch}-$index',
          name: name,
          age: age,
          weightKg: weight,
        ),
      );
    }

    if (people.isEmpty) {
      setState(() => _error = l.familyEmpty);
      return;
    }

    await AppScope.of(context).setHousehold(people);
    if (!mounted) return;
    await Navigator.of(context).pushNamed('/needs');
  }
}

class _Draft {
  _Draft({
    this.id,
    required this.name,
    required this.age,
    required this.weight,
  });

  factory _Draft.fromPerson(Person person) => _Draft(
    id: person.id,
    name: TextEditingController(text: person.name),
    age: TextEditingController(text: person.age.toString()),
    weight: TextEditingController(
      text: person.weightKg == person.weightKg.roundToDouble()
          ? person.weightKg.toStringAsFixed(0)
          : person.weightKg.toString(),
    ),
  );

  factory _Draft.empty() => _Draft(
    name: TextEditingController(),
    age: TextEditingController(),
    weight: TextEditingController(),
  );

  final String? id;
  final TextEditingController name;
  final TextEditingController age;
  final TextEditingController weight;

  bool get isEmpty =>
      name.text.trim().isEmpty &&
      age.text.trim().isEmpty &&
      weight.text.trim().isEmpty;

  void dispose() {
    name.dispose();
    age.dispose();
    weight.dispose();
  }
}
