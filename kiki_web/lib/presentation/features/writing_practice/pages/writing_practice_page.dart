import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/logging/app_logger.dart';
import '../services/writing_practice_print_service.dart';
import '../widgets/traceable_tianzi_cell.dart';

class WritingPracticeWord {
  const WritingPracticeWord({
    required this.text,
    required this.pinyin,
  });

  final String text;
  final String pinyin;

  factory WritingPracticeWord.fromJson(Map<String, dynamic> json) {
    return WritingPracticeWord(
      text: (json['text'] ?? '').toString(),
      pinyin: (json['pinyin'] ?? '').toString(),
    );
  }
}

class WritingPracticePage extends StatelessWidget {
  const WritingPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final words = _parseWords(Get.arguments);
    final items = words
        .map((word) => WritingPracticePrintItem(
              text: word.text,
              pinyin: word.pinyin,
            ))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F4),
      body: SafeArea(
        child: Column(
          children: [
            _WritingPracticeToolbar(items: items),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _PracticePaper(items: items),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<WritingPracticeWord> _parseWords(dynamic arguments) {
    if (arguments is! Map) return const [];
    final rawWords = arguments['words'];
    if (rawWords is! List) return const [];
    return rawWords
        .whereType<Map>()
        .map((raw) => WritingPracticeWord.fromJson(
              Map<String, dynamic>.from(raw),
            ))
        .where((word) => word.text.trim().isNotEmpty)
        .toList(growable: false);
  }
}

class _WritingPracticeToolbar extends StatelessWidget {
  const _WritingPracticeToolbar({required this.items});

  final List<WritingPracticePrintItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: '返回',
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Text(
              '每日一练',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF32343A),
              ),
            ),
          ),
          IconButton(
            tooltip: '打印',
            onPressed: items.isEmpty
                ? null
                : () async {
                    try {
                      await printWritingPracticePage(items: items);
                    } catch (error, stackTrace) {
                      AppLogger.error('Failed to print writing practice page',
                          error, stackTrace);
                      Get.snackbar(
                        '无法打印',
                        '请检查系统打印服务或网络字体加载后重试',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
            icon: const Icon(Icons.print_rounded),
          ),
        ],
      ),
    );
  }
}

class _PracticePaper extends StatelessWidget {
  const _PracticePaper({required this.items});

  static const int _cellsPerLine = 10;

  final List<WritingPracticePrintItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, paperConstraints) {
        final paperWidth = paperConstraints.maxWidth.isFinite
            ? paperConstraints.maxWidth
            : 720.0;
        return Container(
          constraints: BoxConstraints(minHeight: paperWidth * 297 / 210),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF0B8CA), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = ((constraints.maxWidth - 18) / _cellsPerLine)
                  .clamp(32.0, 54.0)
                  .toDouble();
              final rows = _PracticeLayout.buildRows(
                items: items,
                cellsPerLine: _cellsPerLine,
              );
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(child: Text('暂无练习字')),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: rows
                            .map(
                              (row) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PracticeGridRow(
                                  cells: row,
                                  cellSize: cellSize,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FooterLine(label: '日期：'),
                        Text(
                          '评分：☆☆☆☆☆',
                          style: TextStyle(
                            color: Color(0xFFE9A0B8),
                            fontSize: 13,
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
      },
    );
  }
}

class _PracticeGridRow extends StatelessWidget {
  const _PracticeGridRow({
    required this.cells,
    required this.cellSize,
  });

  final List<_PracticeCell> cells;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cells
              .map(
                (cell) => TraceableTianziCell(
                  character: cell.character,
                  pinyin: cell.pinyin,
                  size: cellSize,
                  blank: cell.isBlank,
                  showPinyinHeader: true,
                ),
              )
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cells
              .map(
                (cell) => TraceableTianziCell(
                  character: cell.character,
                  size: cellSize,
                  blank: cell.isBlank,
                  ghost: !cell.isBlank,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PracticeCell {
  const _PracticeCell({
    this.character = '',
    this.pinyin,
    this.isBlank = false,
  });

  final String character;
  final String? pinyin;
  final bool isBlank;
}

class _PracticeLayout {
  static List<List<_PracticeCell>> buildRows({
    required List<WritingPracticePrintItem> items,
    required int cellsPerLine,
  }) {
    final rows = <List<_PracticeCell>>[];
    var row = <_PracticeCell>[];

    void flush() {
      if (row.isEmpty) return;
      while (row.length < cellsPerLine) {
        row.add(const _PracticeCell(isBlank: true));
      }
      rows.add(row);
      row = <_PracticeCell>[];
    }

    for (final item in items) {
      final wordCells = <_PracticeCell>[];
      final characters = item.characters;
      for (var i = 0; i < characters.length; i++) {
        wordCells.add(
          _PracticeCell(
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
        row.add(const _PracticeCell(isBlank: true));
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

class _FooterLine extends StatelessWidget {
  const _FooterLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFE9A0B8), fontSize: 13),
        ),
        Container(
          width: 92,
          height: 1,
          color: const Color(0xFFF0B8CA),
        ),
      ],
    );
  }
}
