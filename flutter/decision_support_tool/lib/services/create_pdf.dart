import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CreatePDF {
  /// Generate PDF matching the exact format of the example
  static Future<void> generatePDF({
    required String evaluatorName,
    required String projectName,
    required String date,
    required String jurisdiction,
    required List<Map<String, dynamic>> step1Answers,
    required List<Map<String, dynamic>> step2Answers,
    required List<Map<String, dynamic>> categories,
    required List<List<List<int>>> radioValues,
    required List<String> justifications,
    required bool goodHighlight,
    required bool betterHighlight,
    required bool bestHighlight,
  }) async {
    final pdf = pw.Document();

    // Page 1: Title/Cover Page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Decision Support Tool for Project: $projectName',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            pw.Text('Name of Evaluator: $evaluatorName'),
            pw.Text('Name of Project: $projectName'),
            pw.Text('Date: $date'),
            pw.Text('Jurisdiction: $jurisdiction'),
          ],
        ),
      ),
    );

    // Pages 2-3: Step 1 (split into 2 pages, ~6 questions each)
    for (var i = 0; i < step1Answers.length; i += 6) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (i == 0)
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 15),
                  child: pw.Text(
                    'Step 1',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ...step1Answers
                  .skip(i)
                  .take(6)
                  .map((q) => _buildQuestionBlock(q)),
            ],
          ),
        ),
      );
    }

    // Page 4: Step 2
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Step 2',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            ...step2Answers.map((q) => _buildQuestionBlock(q)),
          ],
        ),
      ),
    );

    // Pages 5-9: Step 3 (landscape, ~2 categories per page)
    for (var i = 0; i < categories.length; i += 2) {
      final cats = categories.skip(i).take(2).toList();
      final vals = radioValues.skip(i).take(2).toList();
      final justs = justifications.skip(i).take(2).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter.landscape,
          margin: pw.EdgeInsets.all(15),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (i == 0)
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text(
                    'Step 3',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              pw.Expanded(
                child: _buildStep3Table(
                  cats,
                  vals,
                  justs,
                  i,
                  goodHighlight,
                  betterHighlight,
                  bestHighlight,
                  i == 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Build question block for Step 1/2
  static pw.Widget _buildQuestionBlock(Map<String, dynamic> q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          q['question'],
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(q['instruction'], style: pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 3),
        _buildOptionsRow(q['optionLabels'], q['selected']),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              '${q['category']} ${q['points']}/${q['maxPoints']}',
              style: pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  /// Build options row with yellow highlight for selected
  static pw.Widget _buildOptionsRow(List<String> labels, int selected) {
    return pw.Wrap(
      spacing: 3,
      children: List.generate(labels.length, (i) {
        return pw.Container(
          padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: pw.BoxDecoration(
            color: i == selected ? PdfColors.yellow200 : null,
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Text(labels[i], style: pw.TextStyle(fontSize: 7)),
        );
      }),
    );
  }

  /// Build Step 3 table
  static pw.Widget _buildStep3Table(
    List<Map<String, dynamic>> cats,
    List<List<List<int>>> vals,
    List<String> justs,
    int startIdx,
    bool goodHL,
    bool betterHL,
    bool bestHL,
    bool showHeader,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(2.3),
        2: pw.FlexColumnWidth(2.3),
        3: pw.FlexColumnWidth(2.3),
        4: pw.FlexColumnWidth(1.2),
      },
      children: [
        if (showHeader)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.blue400),
            children: [
              _hCell('Category'),
              _hCell(
                'Good for health promotion',
                bg: goodHL ? PdfColors.green400 : PdfColors.blueGrey,
              ),
              _hCell(
                'Better for health promotion',
                bg: betterHL ? PdfColors.green400 : PdfColors.blueGrey,
              ),
              _hCell(
                'Best for health promotion',
                bg: bestHL ? PdfColors.green400 : PdfColors.blueGrey,
              ),
              _hCell('Justification'),
            ],
          ),
        ...List.generate(cats.length, (i) {
          return pw.TableRow(
            children: [
              _catCell('${startIdx + i + 1}: ${cats[i]['title']}'),
              _optsCell(cats[i]['goodHealth'], vals[i][0], goodHL),
              _optsCell(cats[i]['betterHealth'], vals[i][1], betterHL),
              _optsCell(cats[i]['bestHealth'], vals[i][2], bestHL),
              _justCell(justs[i]),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _hCell(String txt, {PdfColor? bg}) => pw.Container(
    padding: pw.EdgeInsets.all(5),
    color: bg,
    child: pw.Text(
      txt,
      style: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );

  static pw.Widget _catCell(String txt) => pw.Container(
    padding: pw.EdgeInsets.all(5),
    child: pw.Text(
      txt,
      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _optsCell(List<String> opts, List<int> sels, bool hl) =>
      pw.Container(
        padding: pw.EdgeInsets.all(5),
        color: hl ? PdfColors.green50 : null,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: List.generate(opts.length, (i) {
            final isSel = sels[i] == i;
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontSize: 7)),
                  pw.Expanded(
                    child: pw.Text(
                      opts[i],
                      style: pw.TextStyle(
                        fontSize: 6,
                        fontWeight: isSel ? pw.FontWeight.bold : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );

  static pw.Widget _justCell(String txt) => pw.Container(
    padding: pw.EdgeInsets.all(5),
    child: pw.Text(txt, style: pw.TextStyle(fontSize: 6)),
  );
}
