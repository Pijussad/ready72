import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the checklist PDF builds with the bundled Inter font', () async {
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
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => [
          pw.Text('READY72 · Ona · 6.7 / 7.4 kg'),
          pw.Text('45 l backpack ×1 · 1.2 kg'),
          pw.Text('AKVILĖ still mineral water ×3 · 4.5 kg'),
          pw.Text('Iš namų: dokumentai, vaistai, telefonas.'),
        ],
      ),
    );
    final bytes = await doc.save();
    expect(bytes.length, greaterThan(1000));
  });
}
