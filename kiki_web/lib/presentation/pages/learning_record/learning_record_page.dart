import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/design_ui/kiki_ui_kit.dart';
import '../../../data/models/learning/scene_progress.dart';
import '../../controllers/learning_record_controller.dart';
import '../../widgets/glass_back_button.dart';

class LearningRecordPage extends StatefulWidget {
  const LearningRecordPage({Key? key}) : super(key: key);

  @override
  State<LearningRecordPage> createState() => _LearningRecordPageState();
}

class _LearningRecordPageState extends State<LearningRecordPage>
    with SingleTickerProviderStateMixin {
  late final LearningRecordController _controller;
  final RxString _viewMode = 'week'.obs; // 'week' or 'month'
  final Rx<DateTime?> _selectedDate = Rx<DateTime?>(null); // For month view day selection
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(LearningRecordController());
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  ROOT BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: KikiUiDecor.pageBackgroundDecor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              Expanded(
                // AnimatedBuilder keeps Animation outside Obx to
                // avoid GetX treating the Listenable as a reactive dep.
                child: AnimatedBuilder(
                  animation: _fadeAnim,
                  builder: (ctx, child) =>
                      Opacity(opacity: _fadeAnim.value, child: child),
                  child: Obx(() {
                    if (_controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6DBF4A)),
                        ),
                      );
                    }
                    if (_controller.errorMessage.value.isNotEmpty) {
                      return _buildErrorState();
                    }
                    if (_controller.activeMonths.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMainContent();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOP BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          GlassBackButton(
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          const Text(
            '学习记录',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Fredoka',
              color: Color(0xFF5A3A15),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MAIN SCROLLABLE CONTENT  (top → bottom)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMainContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── 1. Green Hero Stats ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: _buildHeroCard(),
          ),
        ),

        // ── 2. Week/Month Toggle ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _buildViewModeToggle(),
          ),
        ),

        // ── 3. Content based on view mode ─────────────────────
        Obx(() {
          if (_viewMode.value == 'month') {
            return SliverToBoxAdapter(child: _buildMonthView());
          } else {
            return SliverToBoxAdapter(child: _buildWeekView());
          }
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HERO CARD  (green gradient, full width)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroCard() {
    // ── 全量汇总：不区分月份 ──────────────────────────────────
    int stars = 0, secs = 0, clicks = 0;
    for (final p in _controller.progressList) {
      stars += p.starsEarned;
      secs += p.totalStudyTime;
      clicks += p.learnedCount;
    }
    final mins = (secs / 60).ceil();
    final days = _controller.dailyRecords.length; // unique study days

    final statItems = [
      {'icon': Icons.calendar_today_rounded, 'value': '$days', 'label': '打卡天数'},
      {'icon': Icons.star_rounded,            'value': '$stars', 'label': '获得星星'},
      {'icon': Icons.timer_outlined,          'value': '$mins',  'label': '学习分钟'},
      {'icon': Icons.touch_app_outlined,      'value': '$clicks','label': '词语'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7DD84A), Color(0xFF4DB81C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5CB833).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: title block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 17),
                  const SizedBox(width: 7),
                  const Text(
                    '学习概览',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Fredoka',
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '继续保持，宝贝很棒 🌟',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: 4 stat columns with dividers
          Row(
            children: statItems.asMap().entries.map((e) {
              final idx = e.key;
              final s = e.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (idx > 0)
                    Container(
                      width: 1,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      color: Colors.white.withOpacity(0.3),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s['icon'] as IconData,
                          size: 14, color: Colors.white70),
                      const SizedBox(height: 4),
                      Text(
                        s['value'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Fredoka',
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MONTH PILLS (removed - no longer needed)
  // ═══════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════
  //  VIEW MODE TOGGLE (Week / Month)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildViewModeToggle() {
    return Obx(() {
      final isWeek = _viewMode.value == 'week';
      return Row(
        children: [
          _buildToggleButton('周', isWeek, () => _viewMode.value = 'week'),
          const SizedBox(width: 8),
          _buildToggleButton('月', !isWeek, () => _viewMode.value = 'month'),
        ],
      );
    });
  }

  Widget _buildToggleButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6DBF4A)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF52A836)
                : const Color(0xFFDDD0BC),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6DBF4A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            fontFamily: 'Fredoka',
            color: selected ? Colors.white : const Color(0xFF7A4A22),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MONTH VIEW (Calendar + Scene List)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMonthView() {
    final now = DateTime.now();
    final currentMonth = now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          _buildSectionTitle2('$currentMonth月学习轨迹'),
          const SizedBox(height: 12),

          // Calendar grid
          _buildMonthCalendar(now),
          const SizedBox(height: 20),

          // Scene list based on selected date
          Obx(() => _buildMonthSceneList()),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1=Monday, 7=Sunday
    final daysInMonth = lastDay.day;

    // Calculate total cells needed (including leading empty cells)
    final totalCells = startWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DECA), width: 1.2),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map((d) => SizedBox(
                      width: 28,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          ...List.generate(rows, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final dayNumber = cellIndex - (startWeekday - 2);

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 28, height: 28);
                  }

                  final date = DateTime(month.year, month.month, dayNumber);
                  return _buildCalendarDay(date);
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final records = _controller.dailyRecords[dateKey] ?? [];
    final hasActivity = records.isNotEmpty;
    final stars = records.fold<int>(0, (s, p) => s + p.starsEarned);
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isFuture = date.isAfter(now);

    final isSelected = _selectedDate.value != null &&
        _selectedDate.value!.year == date.year &&
        _selectedDate.value!.month == date.month &&
        _selectedDate.value!.day == date.day;

    // Color scale
    final Color bgColor = isFuture
        ? const Color(0xFFF0EBE3)
        : !hasActivity
            ? const Color(0xFFFFFBF5)
            : stars == 1
                ? const Color(0xFFC6E9A7)
                : stars >= 2
                    ? const Color(0xFF88D45D)
                    : const Color(0xFF4DB81C);

    return GestureDetector(
      onTap: () {
        if (!isFuture && hasActivity) {
          _selectedDate.value = isSelected ? null : date;
        }
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: const Color(0xFF4DB81C), width: 2)
              : isSelected
                  ? Border.all(color: const Color(0xFF52A836), width: 2.5)
                  : null,
        ),
        child: Center(
          child: hasActivity && (stars >= 3 || isSelected)
              ? const Icon(Icons.star_rounded, size: 12, color: Colors.white)
              : Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: hasActivity
                        ? const Color(0xFF5A3A15)
                        : Colors.grey[400],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMonthSceneList() {
    final selectedDate = _selectedDate.value;

    List<SceneProgress> scenes;
    String title;

    if (selectedDate == null) {
      // Show all current month scenes
      final now = DateTime.now();
      final currentMonthKey = '${now.month}月';
      final weekMap = _controller.groupedRecords[currentMonthKey] ?? {};
      scenes = weekMap.values.expand((list) => list).toList();
      title = '本月全部学习记录';
    } else {
      // Show selected day scenes
      final dateKey = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      scenes = _controller.dailyRecords[dateKey] ?? [];
      title = '${selectedDate.month}月${selectedDate.day}日 学习记录';
    }

    if (scenes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            selectedDate == null ? '本月暂无学习记录' : '当天暂无学习记录',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF5A3A15).withOpacity(0.4),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle2(title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: scenes.map((scene) => _buildSceneCompactCard(scene)).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  WEEK VIEW (Current week learning)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildWeekView() {
    final now = DateTime.now();
    final currentMonthKey = '${now.month}月';

    // Find current week's records
    final weekMap = _controller.groupedRecords[currentMonthKey] ?? {};

    // Calculate current week range
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final currentWeekRange = '${monday.month}月${monday.day}日 - ${sunday.month}月${sunday.day}日';

    final weekProgresses = weekMap[currentWeekRange] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle2('本周学习轨迹'),
          const SizedBox(height: 12),
          if (weekProgresses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  '本周暂无学习记录',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF5A3A15).withOpacity(0.4),
                  ),
                ),
              ),
            )
          else
            _buildWeekCard(currentWeekRange, weekProgresses),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle2(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF88D45D), Color(0xFF4DB81C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Fredoka',
            color: Color(0xFF5A3A15),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  WEEK DOT CARD  (full-width with grid scenes)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildWeekCard(String weekRange, List<SceneProgress> progresses) {
    // Derive week's Monday from first record
    final firstDate =
        (progresses.first.lastLearnedAt ?? progresses.first.firstLearnedAt ?? DateTime.now())
            .toLocal();
    final monday = firstDate.subtract(Duration(days: firstDate.weekday - 1));

    // Map weekday (1~7) → progresses
    final Map<int, List<SceneProgress>> dayMap = {};
    for (final p in progresses) {
      final d =
          (p.lastLearnedAt ?? p.firstLearnedAt ?? DateTime.now()).toLocal();
      dayMap.putIfAbsent(d.weekday, () => []).add(p);
    }

    final weekStars = progresses.fold<int>(0, (s, p) => s + p.starsEarned);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DECA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                    color: const Color(0xFFE8DECA).withOpacity(0.6)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week range + star chip
                Row(
                  children: [
                    const Icon(Icons.date_range_rounded,
                        size: 13, color: Color(0xFF6DBF4A)),
                    const SizedBox(width: 6),
                    Text(
                      weekRange,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A4A22),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    // Star chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: weekStars > 0
                            ? const Color(0xFFFFD65A).withOpacity(0.15)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: weekStars > 0
                              ? const Color(0xFFFFD65A).withOpacity(0.5)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12,
                              color: weekStars > 0
                                  ? const Color(0xFFFFB800)
                                  : Colors.grey[400]),
                          const SizedBox(width: 3),
                          Text(
                            '$weekStars 颗',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: weekStars > 0
                                  ? const Color(0xFF7A4A22)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 7-day dot row
                _buildDotRow(monday, dayMap),
              ],
            ),
          ),

          // ── Scene items (3 per row) ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: progresses
                  .map((p) => _buildSceneCompactCard(p))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── 7-dot row ──────────────────────────────────────────────────

  Widget _buildDotRow(DateTime monday, Map<int, List<SceneProgress>> dayMap) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final wd = i + 1;
        final isFuture = day.isAfter(now);
        final recs = dayMap[wd] ?? [];
        final hasActivity = !isFuture && recs.isNotEmpty;
        final stars = recs.fold<int>(0, (s, p) => s + p.starsEarned);
        final isToday = day.year == now.year &&
            day.month == now.month &&
            day.day == now.day;

        // Colour scale matching main heatmap
        final Color dotColor = isFuture
            ? const Color(0xFFF0EBE3)
            : !hasActivity
                ? const Color(0xFFECE8E0)
                : stars == 1
                    ? const Color(0xFFC6E9A7)
                    : stars == 2
                        ? const Color(0xFF88D45D)
                        : const Color(0xFF4DB81C);

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dot circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(
                          color: const Color(0xFF4DB81C), width: 2)
                      : null,
                  boxShadow: hasActivity
                      ? [
                          BoxShadow(
                            color: dotColor.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: hasActivity
                    ? Center(
                        child: stars >= 3
                            ? const Icon(Icons.star_rounded,
                                size: 12, color: Colors.white)
                            : Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              // Weekday label
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: hasActivity
                      ? const Color(0xFF5A3A15)
                      : Colors.grey[400],
                ),
              ),
              // Date number
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 9,
                  color: isToday
                      ? const Color(0xFF4DB81C)
                      : Colors.grey[400],
                  fontWeight:
                      isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Scene compact card (3 per row) ─────────────────────────────────────────

  Widget _buildSceneCompactCard(SceneProgress p) {
    final d = (p.lastLearnedAt ?? p.firstLearnedAt ?? DateTime.now()).toLocal();
    final dow = _weekdayStr(d.weekday);
    final dateStr = '${d.month}/${d.day}';
    final name = _getSceneName(p.sceneId);
    final mins = (p.totalStudyTime / 60).ceil();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _controller.continueLearning(p.sceneId),
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 3, // 3 cards per row with spacing
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8DECA).withOpacity(0.7), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: Scene name + Stars
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5A3A15),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                // Stars (horizontal)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (si) => Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: si < p.starsEarned
                          ? const Color(0xFFFFB800)
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            // Date
            Text(
              '$dow $dateStr',
              style: TextStyle(
                fontSize: 9,
                color: const Color(0xFF7A4A22).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 6),
            // Stats row (horizontal)
            Row(
              children: [
                _miniChip(Icons.timer_outlined, '$mins\'', 9),
                const SizedBox(width: 8),
                _miniChip(Icons.touch_app_outlined, '${p.learnedCount}词', 9),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Scene row item (removed) ─────────────────────────────────────────

  Widget _miniChip(IconData icon, String text, [double fontSize = 11]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Colors.grey[430]),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(fontSize: fontSize, color: Colors.grey[500]),
        ),
      ],
    );
  }


  // ═══════════════════════════════════════════════════════════════
  //  EMPTY / ERROR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3CC), Color(0xFFFFE077)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD65A).withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 44, color: Color(0xFFFFB800)),
          ),
          const SizedBox(height: 22),
          const Text(
            '还没有学习记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Fredoka',
              color: Color(0xFF5A3A15),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去点击场景卡片，点亮第一颗星星吧 🌟',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF5A3A15).withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 56, color: Color(0xFFFF8B8B)),
          const SizedBox(height: 16),
          Text(
            _controller.errorMessage.value,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _controller.loadRecords(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6DBF4A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  String _weekdayStr(int wd) {
    const map = {
      1: '周一', 2: '周二', 3: '周三',
      4: '周四', 5: '周五', 6: '周六', 7: '周日',
    };
    return map[wd] ?? '';
  }

  String _getSceneName(String sceneId) {
    final cached = _controller.sceneNames[sceneId];
    if (cached != null) return cached;
    if (sceneId.contains('zhiwuyuan')) return '神奇植物园';
    if (sceneId.contains('dongwuyuan')) return '欢乐动物园';
    if (sceneId.contains('toy')) return '多彩玩具世界';
    return sceneId;
  }
}
