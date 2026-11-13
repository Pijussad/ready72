import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/plan.dart';
import '../services/app_state.dart';
import '../theme/design.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppScope.of(context);
    final person = state.packPerson;
    final plan = state.selectedPlan;

    if (person == null || plan == null) {
      return AppScreen(
        center: false,
        footer: PrimaryButton(
          label: l.back,
          onPressed: () => Navigator.of(context).pushNamed('/home'),
        ),
        child: Text(l.noItems, style: AppType.body),
      );
    }

    final bag = plan.bags[person.id]!;
    final items = plan.itemsForCarrier(person.id).toList()
      ..sort((a, b) {
        final byPriority = a.product.priority.index.compareTo(
          b.product.priority.index,
        );
        if (byPriority != 0) return byPriority;
        return a.product
            .name(state.locale)
            .compareTo(b.product.name(state.locale));
      });

    return AppScreen(
      center: false,
      footer: PrimaryButton(
        label: l.printChecklist,
        onPressed: () => _print(context, l, state, person.name, bag, items),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.checklistTitle, style: AppType.h1),
          const SizedBox(height: 8),
          Text(l.checklistSub, style: AppType.body),
          const SizedBox(height: 18),
          PersonSelector(
            names: [
              for (final entry in state.household)
                (id: entry.id, name: entry.name),
            ],
            selectedId: person.id,
            onSelect: state.setPackPerson,
          ),
          const SizedBox(height: 14),
          Text(
            l.checklistHeader(
              person.name,
              formatWeight(bag.weightKg),
              formatWeight(bag.limitKg),
            ),
            style: AppType.label.copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            CheckLine(
              selected: state.pack.entryFor(item.key).checked,
              label:
                  '${item.product.name(state.locale)} · '
                  '${formatWeight(item.weightKg)} kg',
              onTap: () => state.togglePacked(item),
            ),
          const Hairline(),
          const SizedBox(height: 14),
          Text(l.checklistFromHome, style: AppType.small),
          QuietLink(
            label: l.copyChecklist,
            textAlign: TextAlign.left,
            onTap: () => _copy(context, l, state, person.name, bag, items),
          ),
        ],
      ),
    );
  }

  Future<void> _print(
    BuildContext context,
    AppLocalizations l,
    AppState state,
    String name,
    PersonBag bag,
    List<PlanItem> items,
  ) async {
    try {
      final regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
      );
      final bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Inter-Medium.ttf'),
      );
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
          build: (context) => [
            pw.Text(
              'READY72',
              style: pw.TextStyle(font: bold, fontSize: 10, letterSpacing: 2),
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              l.checklistHeader(
                name,
                formatWeight(bag.weightKg),
                formatWeight(bag.limitKg),
              ),
              style: pw.TextStyle(font: bold, fontSize: 18),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              l.checklistSub,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 14),
            for (final item in items)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 16,
                      child: pw.Text(
                        state.pack.entryFor(item.key).checked ? 'x' : '',
                        style: pw.TextStyle(font: bold, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '${item.product.name(state.locale)} ×${item.quantity}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      '${formatWeight(item.weightKg)} kg',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            pw.SizedBox(height: 16),
            pw.Text(
              l.checklistFromHome,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      );
      await Printing.layoutPdf(onLayout: (format) => doc.save());
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.printFailed,
            style: AppType.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
    }
  }

  Future<void> _copy(
    BuildContext context,
    AppLocalizations l,
    AppState state,
    String name,
    PersonBag bag,
    List<PlanItem> items,
  ) async {
    final buffer = StringBuffer()
      ..writeln(
        l.checklistHeader(
          name,
          formatWeight(bag.weightKg),
          formatWeight(bag.limitKg),
        ),
      )
      ..writeln();
    for (final item in items) {
      final checked = state.pack.entryFor(item.key).checked;
      buffer.writeln(
        '[${checked ? 'x' : ' '}] ${item.product.name(state.locale)} '
        '×${item.quantity} · ${formatWeight(item.weightKg)} kg',
      );
    }
    buffer
      ..writeln()
      ..writeln(l.checklistFromHome);
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l.checklistCopied,
          style: AppType.body.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.ink,
      ),
    );
  }
}
