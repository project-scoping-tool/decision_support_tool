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
    double pagePadding = 50.0;

    // Load font with Unicode support
    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.robotoRegular(),
      bold: await PdfGoogleFonts.robotoBold(),
    );

    // Build content for each page
    List<pw.Widget> titlePage = _buildTitlePage(
      evaluatorName,
      projectName,
      date,
      jurisdiction,
    );

    List<pw.Widget> step1Body_0 = _buildStep1(step1Answers, 0, 6);
    List<pw.Widget> step1Body_1 = _buildStep1(
      step1Answers,
      6,
      step1Answers.length,
    );

    List<pw.Widget> step2Body = _buildStep2(step2Answers);

    List<pw.Widget> step3Body_0 = _buildStep3(
      categories,
      radioValues,
      justifications,
      0,
      2,
      true,
      goodHighlight,
      betterHighlight,
      bestHighlight,
    );
    List<pw.Widget> step3Body_1 = _buildStep3(
      categories,
      radioValues,
      justifications,
      2,
      4,
      false,
      goodHighlight,
      betterHighlight,
      bestHighlight,
    );
    List<pw.Widget> step3Body_2 = _buildStep3(
      categories,
      radioValues,
      justifications,
      4,
      6,
      false,
      goodHighlight,
      betterHighlight,
      bestHighlight,
    );
    List<pw.Widget> step3Body_3 = _buildStep3(
      categories,
      radioValues,
      justifications,
      6,
      8,
      false,
      goodHighlight,
      betterHighlight,
      bestHighlight,
    );
    List<pw.Widget> step3Body_4 = _buildStep3(
      categories,
      radioValues,
      justifications,
      8,
      categories.length,
      false,
      goodHighlight,
      betterHighlight,
      bestHighlight,
    );

    // Page 1: Title/Cover Page
    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Spacer(),
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 10.0),
                  child: pw.Text(
                    'Decision Support Tool for Project: $projectName',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: titlePage,
                ),
                pw.Spacer(),
              ],
            ),
          );
        },
      ),
    );

    // Pages 2-3: Step 1
    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 10.0),
                  child: pw.Text(
                    'Step 1',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                pw.Column(children: step1Body_0),
              ],
            ),
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(children: step1Body_1),
          );
        },
      ),
    );

    // Page 4: Step 2
    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 10.0),
                  child: pw.Text(
                    'Step 2',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                pw.Column(children: step2Body),
              ],
            ),
          );
        },
      ),
    );

    // Pages 5-9: Step 3 (landscape)
    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 10.0),
                  child: pw.Text(
                    'Step 3',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                pw.Column(children: step3Body_0),
              ],
            ),
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(children: step3Body_1),
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(children: step3Body_2),
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(children: step3Body_3),
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginAll: 1.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(right: pagePadding),
            child: pw.Column(children: step3Body_4),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Build title page content
  static List<pw.Widget> _buildTitlePage(
    String evaluatorName,
    String projectName,
    String date,
    String jurisdiction,
  ) {
    List<pw.Widget> titlePage = [];
    double fontSize = 15.0;
    double titleWidth = 150.0;

    titlePage.add(pw.Padding(padding: pw.EdgeInsets.only(left: 250.0)));

    titlePage.add(
      pw.Container(
        alignment: pw.Alignment.centerLeft,
        width: titleWidth,
        child: pw.Column(
          children: [
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Name of Evaluator:',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Name of Project:',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Jurisdiction:',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Date:',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    titlePage.add(
      pw.Container(
        alignment: pw.Alignment.centerLeft,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                evaluatorName,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                projectName,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                jurisdiction,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                date,
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return titlePage;
  }

  /// Build Step 1 content
  static List<pw.Widget> _buildStep1(
    List<Map<String, dynamic>> step1Answers,
    int start,
    int end,
  ) {
    final lowSoftColor = PdfColors.grey200;
    final lowHardColor = PdfColors.blueGrey100;
    List<pw.Widget> step1 = [];
    double fontSize = 10.0;

    for (int i = start; i < end && i < step1Answers.length; i++) {
      PdfColor bgColor = (i - start) % 2 == 0 ? lowSoftColor : lowHardColor;
      Map<String, dynamic> q = step1Answers[i];

      step1.add(
        pw.Container(
          height: 70.0,
          child: pw.Container(
            color: bgColor,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // 1st Column - Question and answers
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 5.0,
                  ),
                  width: 620.0,
                  child: pw.Column(
                    children: [
                      // Question
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Container(
                          padding: pw.EdgeInsets.all(3.0),
                          child: pw.Text(
                            q['question'],
                            style: pw.TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ),
                      // Instruction
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.only(left: 5.0),
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              q['instruction'],
                              style: pw.TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ],
                      ),
                      pw.Container(padding: pw.EdgeInsets.only(top: 1.0)),
                      // Answer options
                      pw.Container(
                        child: pw.Row(
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  child: pw.Text(
                                    q['category'],
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.only(
                                right: 30.0,
                                left: 10.0,
                              ),
                              width: 570.0,
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: _buildAnswersRow(
                                  q['optionLabels'],
                                  q['selected'],
                                  bgColor,
                                  fontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(padding: pw.EdgeInsets.only(top: 1.0)),
                    ],
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                // 2nd column - Domain
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: pw.Alignment.center,
                  color: bgColor,
                  width: 75.0,
                  child: pw.Text(
                    q['category'],
                    style: pw.TextStyle(
                      fontSize: fontSize,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                // 3rd column - Points
                pw.Container(
                  alignment: pw.Alignment.center,
                  color: bgColor,
                  width: 35.0,
                  child: pw.Text(
                    '${q['points']}/${q['maxPoints']}',
                    style: pw.TextStyle(
                      fontSize: fontSize,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return step1;
  }

  /// Build answer options row
  static List<pw.Widget> _buildAnswersRow(
    List<String> labels,
    int selected,
    PdfColor backgroundColor,
    double fontSize,
  ) {
    List<pw.Widget> widgets = [];

    for (int i = 0; i < labels.length; i++) {
      widgets.add(
        pw.Container(
          padding: pw.EdgeInsets.symmetric(
            horizontal: 150.0 / labels.length,
            vertical: 1.0,
          ),
          child: pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 3.0),
            color: backgroundColor,
            child: pw.Text(
              labels[i],
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: fontSize,
                fontWeight: i == selected
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build Step 2 content
  static List<pw.Widget> _buildStep2(List<Map<String, dynamic>> step2Answers) {
    final lowSoftColor = PdfColors.grey200;
    final lowHardColor = PdfColors.blueGrey100;
    List<pw.Widget> step2 = [];
    double fontSize = 10.0;

    for (int i = 0; i < step2Answers.length; i++) {
      PdfColor bgColor = i % 2 == 0 ? lowSoftColor : lowHardColor;
      Map<String, dynamic> q = step2Answers[i];

      step2.add(
        pw.Container(
          height: 70.0,
          child: pw.Container(
            color: bgColor,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // 1st Column
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 5.0,
                  ),
                  width: 670.0,
                  child: pw.Column(
                    children: [
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Container(
                          padding: pw.EdgeInsets.all(3.0),
                          child: pw.Text(
                            q['question'],
                            style: pw.TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ),
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.only(left: 5.0),
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              q['instruction'],
                              style: pw.TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ],
                      ),
                      pw.Container(padding: pw.EdgeInsets.only(top: 1.0)),
                      pw.Container(
                        child: pw.Row(
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  child: pw.Text(
                                    q['category'],
                                    style: pw.TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.only(
                                right: 30.0,
                                left: 10.0,
                              ),
                              width: 625.0,
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: _buildAnswersRow(
                                  q['optionLabels'],
                                  q['selected'],
                                  bgColor,
                                  fontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(padding: pw.EdgeInsets.only(top: 1.0)),
                    ],
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                // 2nd column - Points
                pw.Container(
                  alignment: pw.Alignment.center,
                  color: bgColor,
                  width: 65.0,
                  child: pw.Text(
                    '${q['points']}/${q['maxPoints']}',
                    style: pw.TextStyle(
                      fontSize: fontSize - 2,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return step2;
  }

  /// Build Step 3 content
  static List<pw.Widget> _buildStep3(
    List<Map<String, dynamic>> categories,
    List<List<List<int>>> radioValues,
    List<String> justifications,
    int startIndex,
    int endIndex,
    bool hasHeader,
    bool goodHighlight,
    bool betterHighlight,
    bool bestHighlight,
  ) {
    final highSoftColor = PdfColors.green50;
    final lowSoftColor = PdfColors.grey200;
    final lowHardColor = PdfColors.blueGrey100;
    List<pw.Widget> rows = [];
    double fontSize = 10.0;
    double columnWidth = 145.0;
    PdfColor headerHighlight = PdfColors.greenAccent700;

    // Add header for Step 3
    if (hasHeader) {
      rows.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 3.0),
          child: pw.Container(
            height: 50.0,
            child: pw.Row(
              children: [
                pw.Container(
                  color: PdfColors.blue400,
                  width: columnWidth,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Category',
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                pw.Container(
                  color: goodHighlight ? headerHighlight : PdfColors.blue400,
                  width: columnWidth,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Good for health promotion',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                pw.Container(
                  color: betterHighlight ? headerHighlight : PdfColors.blue400,
                  width: columnWidth,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Better for health promotion',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                pw.Container(
                  color: bestHighlight ? headerHighlight : PdfColors.blue400,
                  width: columnWidth,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Best for health promotion',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.Container(width: 3.0, color: PdfColors.white),
                pw.Container(
                  color: PdfColors.blue400,
                  width: columnWidth,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Justification',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Add category rows
    for (int i = startIndex; i < endIndex && i < categories.length; i++) {
      PdfColor bgColor = (i - startIndex) % 2 == 0
          ? lowSoftColor
          : lowHardColor;
      PdfColor bgHighlight = highSoftColor;

      Map<String, dynamic> cat = categories[i];
      List<List<int>> vals = radioValues[i];
      String just = justifications[i];

      // Build options columns
      List<pw.Widget> goodOptions = _buildOptionsColumn(
        cat['goodHealth'],
        vals[0],
        goodHighlight ? bgHighlight : bgColor,
        columnWidth,
        fontSize,
      );

      List<pw.Widget> betterOptions = _buildOptionsColumn(
        cat['betterHealth'],
        vals[1],
        betterHighlight ? bgHighlight : bgColor,
        columnWidth,
        fontSize,
      );

      List<pw.Widget> bestOptions = _buildOptionsColumn(
        cat['bestHealth'],
        vals[2],
        bestHighlight ? bgHighlight : bgColor,
        columnWidth,
        fontSize,
      );

      rows.add(
        pw.Container(
          color: bgColor,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: columnWidth,
                child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(5.0),
                    child: pw.Text(
                      '${i + 1}: ${cat['title']}',
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pw.Container(width: 3.0, color: PdfColors.white),
              pw.Container(
                color: goodHighlight ? bgHighlight : bgColor,
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.symmetric(horizontal: 3.0),
                width: columnWidth,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: goodOptions,
                ),
              ),
              pw.Container(width: 3.0, color: PdfColors.white),
              pw.Container(
                color: betterHighlight ? bgHighlight : bgColor,
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.symmetric(horizontal: 3.0),
                width: columnWidth,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: betterOptions,
                ),
              ),
              pw.Container(width: 3.0, color: PdfColors.white),
              pw.Container(
                color: bestHighlight ? bgHighlight : bgColor,
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.symmetric(horizontal: 3.0),
                width: columnWidth,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: bestOptions,
                ),
              ),
              pw.Container(width: 3.0, color: PdfColors.white),
              pw.Container(
                padding: pw.EdgeInsets.all(4.0),
                width: columnWidth,
                child: pw.Text(just, style: pw.TextStyle(fontSize: fontSize)),
              ),
            ],
          ),
        ),
      );

      if (i < endIndex - 1 && i < categories.length - 1) {
        rows.add(pw.Container(height: 3.0, color: PdfColors.white));
      }
    }

    return rows;
  }

  /// Build options column for Step 3
  static List<pw.Widget> _buildOptionsColumn(
    List<String> options,
    List<int> selections,
    PdfColor bgColor,
    double columnWidth,
    double fontSize,
  ) {
    List<pw.Widget> widgets = [];

    for (int i = 0; i < options.length; i++) {
      bool isSelected = selections[i] == i;
      widgets.add(
        pw.Container(
          width: columnWidth - 6.0,
          color: bgColor,
          child: pw.Padding(
            padding: pw.EdgeInsets.all(3.0),
            child: pw.Text(
              '\u2022 ${options[i]}',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
