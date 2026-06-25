import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class WritingPracticePrintItem {
  const WritingPracticePrintItem({
    required this.text,
    required this.pinyin,
  });

  final String text;
  final String pinyin;

  List<String> get characters => text.runes
      .map(String.fromCharCode)
      .where((char) => char.trim().isNotEmpty)
      .toList(growable: false);

  List<String> get pinyinParts => pinyin
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList(growable: false);

  String pinyinForIndex(int index) {
    final parts = pinyinParts;
    if (index < parts.length) return parts[index];
    return pinyin;
  }
}

class WritingPracticePrintCell {
  const WritingPracticePrintCell({
    this.character = '',
    this.pinyin,
    this.isBlank = false,
  });

  final String character;
  final String? pinyin;
  final bool isBlank;
}

class WritingPracticePrintLayout {
  static const int cellsPerLine = 10;

  static List<List<WritingPracticePrintCell>> buildRows(
    List<WritingPracticePrintItem> items,
  ) {
    final rows = <List<WritingPracticePrintCell>>[];
    var row = <WritingPracticePrintCell>[];

    void flush() {
      if (row.isEmpty) return;
      while (row.length < cellsPerLine) {
        row.add(const WritingPracticePrintCell(isBlank: true));
      }
      rows.add(row);
      row = <WritingPracticePrintCell>[];
    }

    for (final item in items) {
      final wordCells = <WritingPracticePrintCell>[];
      final characters = item.characters;
      for (var i = 0; i < characters.length; i++) {
        wordCells.add(
          WritingPracticePrintCell(
            character: characters[i],
            pinyin: item.pinyinForIndex(i),
          ),
        );
      }

      final requiredCells = wordCells.length + (row.isEmpty ? 0 : 1);
      if (row.isNotEmpty && row.length + requiredCells > cellsPerLine) {
        flush();
      }
      if (row.isNotEmpty) {
        row.add(const WritingPracticePrintCell(isBlank: true));
      }
      row.addAll(wordCells);
      if (row.length >= cellsPerLine) {
        flush();
      }
    }

    flush();
    return rows;
  }
}

Future<void> printWritingPracticePage({
  required List<WritingPracticePrintItem> items,
}) async {
  final bytes = await _buildPracticePdf(items);
  await Printing.layoutPdf(
    name: 'hanzi-writing-practice.pdf',
    format: PdfPageFormat.a4,
    onLayout: (_) async => bytes,
  );
}

Future<Uint8List> _buildPracticePdf(
  List<WritingPracticePrintItem> items,
) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final cjkFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/AR-PL-KaitiM-GB.ttf'),
  );
  final appIcon = pw.MemoryImage(
    (await rootBundle.load('assets/icon/app_icon.png')).buffer.asUint8List(),
  );

  final rows = WritingPracticePrintLayout.buildRows(items);
  final pages = <List<List<WritingPracticePrintCell>>>[];
  for (var i = 0; i < rows.length; i += 12) {
    final end = i + 12 > rows.length ? rows.length : i + 12;
    pages.add(rows.sublist(i, end));
  }

  for (final pageRows in pages) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#C62828')),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.fromLTRB(22, 18, 22, 16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.ClipOval(
                            child: pw.Image(
                              appIcon,
                              width: 34,
                              height: 34,
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            'Hi Kiki',
                            style: pw.TextStyle(
                              font: cjkFont,
                              fontSize: 11,
                              color: PdfColor.fromHex('#C62828'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      '每日一练',
                      style: pw.TextStyle(
                        font: cjkFont,
                        fontSize: 24,
                        color: PdfColor.fromHex('#C62828'),
                      ),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        '正楷：文鼎简中楷',
                        style: pw.TextStyle(
                          font: cjkFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#8A8A8A'),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
                pw.Expanded(
                  child: pw.Stack(
                    children: [
                      ..._buildHiKikiTags(
                        cjkFont: cjkFont,
                        appIcon: appIcon,
                      ),
                      pw.Center(
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: pageRows
                              .map((row) =>
                                  _buildPrintPracticeRow(row, cjkFont))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFooterLine('日期：', cjkFont),
                    pw.Text(
                      '评分：☆☆☆☆☆',
                      style: pw.TextStyle(
                        font: cjkFont,
                        fontSize: 12,
                        color: PdfColor.fromHex('#C62828'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  if (pages.isEmpty) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(
          child: pw.Text('暂无练习字', style: pw.TextStyle(font: cjkFont)),
        ),
      ),
    );
  }

  return pdf.save();
}

List<pw.Widget> _buildHiKikiTags({
  required pw.Font cjkFont,
  required pw.MemoryImage appIcon,
}) {
  return [
    pw.Positioned(
      left: 8,
      top: 10,
      child: pw.Transform.rotate(
        angle: -0.06,
        child: _buildHiKikiTag(cjkFont, appIcon),
      ),
    ),
    pw.Positioned(
      right: 8,
      bottom: 10,
      child: pw.Transform.rotate(
        angle: 0.06,
        child: _buildHiKikiTag(cjkFont, appIcon),
      ),
    ),
  ];
}

pw.Widget _buildHiKikiTag(pw.Font cjkFont, pw.MemoryImage appIcon) {
  return pw.Opacity(
    opacity: 0.72,
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF7F7'),
        border: pw.Border.all(color: PdfColor.fromHex('#C62828'), width: 0.8),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.ClipOval(
            child: pw.Image(
              appIcon,
              width: 14,
              height: 14,
              fit: pw.BoxFit.cover,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Text(
            'Hi Kiki',
            style: pw.TextStyle(
              font: cjkFont,
              fontSize: 8.5,
              color: PdfColor.fromHex('#C62828'),
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _buildPrintPracticeRow(
  List<WritingPracticePrintCell> cells,
  pw.Font cjkFont,
) {
  const cellSize = 44.0;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: cells
            .map(
              (cell) => _buildPrintCell(
                cell.character,
                cell.pinyin,
                cjkFont,
                PdfColors.black,
                cellSize,
                showPinyinHeader: true,
              ),
            )
            .toList(),
      ),
      pw.Row(
        children: cells
            .map(
              (cell) => _buildPrintCell(
                cell.character,
                null,
                cjkFont,
                PdfColor.fromHex('#E57373'),
                cellSize,
                ghost: !cell.isBlank,
              ),
            )
            .toList(),
      ),
      pw.SizedBox(height: 8),
    ],
  );
}

pw.Widget _buildPrintCell(
  String character,
  String? pinyin,
  pw.Font cjkFont,
  PdfColor color,
  double size,
  {
  bool ghost = false,
  bool showPinyinHeader = false,
}
) {
  final headerHeight = showPinyinHeader ? size * 0.34 : 0.0;
  return pw.Container(
    width: size,
    height: size + headerHeight,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromHex('#7F7F7F'), width: 0.8),
    ),
    child: pw.Column(
      children: [
        if (showPinyinHeader)
          pw.Container(
            width: size,
            height: headerHeight,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColor.fromHex('#7F7F7F'),
                  width: 0.8,
                ),
              ),
            ),
            child: pw.Center(
              child: pw.Text(
                pinyin ?? '',
                style: pw.TextStyle(
                  font: cjkFont,
                  fontSize: size * 0.17,
                  color: PdfColor.fromHex('#50565F'),
                ),
              ),
            ),
          ),
        pw.SizedBox(
          width: size,
          height: size,
          child: pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Container(
                    width: 0.45,
                    height: size,
                    color: PdfColor.fromHex('#B9C0C8'),
                  ),
                ),
              ),
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Container(
                    width: size,
                    height: 0.45,
                    color: PdfColor.fromHex('#B9C0C8'),
                  ),
                ),
              ),
              if (character.isNotEmpty)
                pw.Positioned.fill(
                  child: pw.Center(
                    child: pw.Text(
                      character,
                      style: pw.TextStyle(
                        font: cjkFont,
                        fontSize: size * 0.64,
                        color: ghost ? PdfColor.fromHex('#E57373') : color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildFooterLine(String label, pw.Font cjkFont) {
  return pw.Row(
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          font: cjkFont,
          fontSize: 12,
          color: PdfColor.fromHex('#C62828'),
        ),
      ),
      pw.Container(
        width: 120,
        height: 1,
        color: PdfColor.fromHex('#C62828'),
      ),
    ],
  );
}
