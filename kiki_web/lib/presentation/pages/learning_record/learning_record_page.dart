import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/design_ui/kiki_ui_kit.dart';
import '../../../data/models/learning/scene_progress.dart';
import '../../controllers/learning_record_controller.dart';

class LearningRecordPage extends StatefulWidget {
  const LearningRecordPage({Key? key}) : super(key: key);

  @override
  State<LearningRecordPage> createState() => _LearningRecordPageState();
}

class _LearningRecordPageState extends State<LearningRecordPage>
    with SingleTickerProviderStateMixin {
  late final LearningRecordController _controller;
  final RxString _selectedMonth = ''.obs;
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

    ever(_controller.activeMonths, (List<String> months) {
      if (months.isNotEmpty && _selectedMonth.value.isEmpty) {
        _selectedMonth.value = months.first;
        _fadeCtrl.forward();
      }
    });
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
          _roundBtn(
            icon: Icons.arrow_back_ios_new_rounded,
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

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDD0BC)),
          ),
          child: Icon(icon, size: 17, color: const Color(0xFF7A4A22)),
        ),
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

        // ── 2. Month Pill Selector ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildMonthPills(),
          ),
        ),

        // ── 3. Section title "X月 学习轨迹" ─────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Obx(() => _buildSectionTitle()),
          ),
        ),

        // ── 4. Week dot cards ────────────────────────────────────
        Obx(() {
          final month = _selectedMonth.value;
          if (month.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

          final weekMap = _controller.groupedRecords[month] ?? {};
          final sorted =
              weekMap.keys.toList()..sort((a, b) => b.compareTo(a));

          if (sorted.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    '$month 暂无学习记录',
                    style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF5A3A15).withOpacity(0.4)),
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) =>
                    _buildWeekCard(sorted[i], weekMap[sorted[i]]!),
                childCount: sorted.length,
              ),
            ),
          );
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
      {'icon': Icons.touch_app_outlined,      'value': '$clicks','label': '次交互'},
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
  //  MONTH PILLS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMonthPills() {
    return Obx(() {
      final selectedMonth = _selectedMonth.value;
      return SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _controller.activeMonths.length,
          itemBuilder: (_, i) {
            final month = _controller.activeMonths[i];
            final selected = selectedMonth == month;
            return GestureDetector(
              onTap: () {
                _selectedMonth.value = month;
                _fadeCtrl
                  ..reset()
                  ..forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  month,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Fredoka',
                    color: selected ? Colors.white : const Color(0xFF7A4A22),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  SECTION TITLE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSectionTitle() {
    final month = _selectedMonth.value;
    if (month.isEmpty) return const SizedBox();
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
          '$month 学习轨迹',
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
  //  WEEK DOT CARD  (full-width)
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
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
                        size: 15, color: Color(0xFF6DBF4A)),
                    const SizedBox(width: 7),
                    Text(
                      weekRange,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A4A22),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    // Star chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                              size: 14,
                              color: weekStars > 0
                                  ? const Color(0xFFFFB800)
                                  : Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '$weekStars 颗',
                            style: TextStyle(
                              fontSize: 12,
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
                const SizedBox(height: 14),

                // 7-day dot row (full width)
                _buildDotRow(monday, dayMap),
              ],
            ),
          ),

          // ── Scene items ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: progresses
                  .map((p) => _buildSceneItem(p))
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(
                          color: const Color(0xFF4DB81C), width: 2.5)
                      : null,
                  boxShadow: hasActivity
                      ? [
                          BoxShadow(
                            color: dotColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: hasActivity
                    ? Center(
                        child: stars >= 3
                            ? const Icon(Icons.star_rounded,
                                size: 16, color: Colors.white)
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                      )
                    : null,
              ),
              const SizedBox(height: 5),
              // Weekday label
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
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
                  fontSize: 10,
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

  // ── Scene item row ─────────────────────────────────────────────

  Widget _buildSceneItem(SceneProgress p) {
    final d = (p.lastLearnedAt ?? p.firstLearnedAt ?? DateTime.now()).toLocal();
    final dow = _weekdayStr(d.weekday);
    final dateStr = '${d.month}月${d.day}日';
    final name = _getSceneName(p.sceneId);
    final mins = (p.totalStudyTime / 60).ceil();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _controller.continueLearning(p.sceneId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            // Day badge
            Container(
              width: 64,
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFDDD0BC).withOpacity(0.7)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dow,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7A4A22),
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 8.5,
                      color: const Color(0xFF7A4A22).withOpacity(0.5),
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Scene name + stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5A3A15),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _miniChip(Icons.timer_outlined, '$mins 分钟'),
                      const SizedBox(width: 10),
                      _miniChip(
                          Icons.touch_app_outlined, '${p.learnedCount} 次'),
                    ],
                  ),
                ],
              ),
            ),

            // Stars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (si) => Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: si < p.starsEarned
                      ? const Color(0xFFFFB800)
                      : Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.grey[350]),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.grey[430]),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
