import 'dart:developer' as dev;

/// =====================================================
/// TaapdeelPerfBenchmark
/// أضف هذا الكلاس في أي مكان في المشروع
/// واستدعيه من _refreshExploreCategoryChips() و initState()
///
/// الاستخدام:
///   TaapdeelPerfBenchmark.start('probe_loop');
///   // ... الكود اللي تريد تقيسه
///   TaapdeelPerfBenchmark.end('probe_loop');
///   TaapdeelPerfBenchmark.printReport();
/// =====================================================
class TaapdeelPerfBenchmark {
  TaapdeelPerfBenchmark._();

  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _history = {};

  // ✅ ابدأ القياس
  static void start(String tag) {
    _timers[tag] = Stopwatch()..start();
  }

  // ✅ وقّف القياس وسجّل
  static int end(String tag) {
    final sw = _timers[tag];
    if (sw == null) return 0;
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    _history.putIfAbsent(tag, () => []).add(ms);

    // ✅ اطبع فوراً في الـ console مع تمييز لوني
    final emoji = ms < 100 ? '✅' : ms < 300 ? '⚠️' : '🔴';
    dev.log(
      '$emoji [$tag] ${ms}ms',
      name: 'TaapdeelPerf',
      time: DateTime.now(),
    );

    return ms;
  }

  // ✅ اطبع تقرير كامل بكل القياسات
  static void printReport() {
    if (_history.isEmpty) {
      dev.log('No measurements yet', name: 'TaapdeelPerf');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('\n=== Taapdeel Perf Report ===');

    for (final entry in _history.entries) {
      final tag = entry.key;
      final values = entry.value;
      final avg = values.reduce((a, b) => a + b) ~/ values.length;
      final min = values.reduce((a, b) => a < b ? a : b);
      final max = values.reduce((a, b) => a > b ? a : b);

      final bar = _bar(avg);
      final emoji = avg < 100 ? '✅' : avg < 300 ? '⚠️' : '🔴';
      buffer.writeln(
        '$emoji  $tag\n'
        '   avg=${avg}ms  min=${min}ms  max=${max}ms  (n=${values.length})\n'
        '   $bar',
      );
    }

    buffer.writeln('============================');
    dev.log(buffer.toString(), name: 'TaapdeelPerf');
  }

  // ✅ امسح كل القياسات
  static void clear() {
    _timers.clear();
    _history.clear();
  }

  static String _bar(int ms) {
    final filled = (ms / 20).clamp(0, 40).round();
    final empty  = 40 - filled;
    final color  = ms < 100 ? '█' : ms < 300 ? '▓' : '░';
    return '[${color * filled}${' ' * empty}] ${ms}ms';
  }
}


/// =====================================================
/// إزاي تستخدمه في الكود
/// =====================================================
///
/// 1️⃣ في _HomeDashboardViewWidgetState.didChangeDependencies:
///    TaapdeelPerfBenchmark.start('home_init');
///
/// 2️⃣ في بداية _refreshExploreCategoryChips:
///    TaapdeelPerfBenchmark.start('probe_explore');
///
/// 3️⃣ في نهاية _refreshExploreCategoryChips (قبل آخر if):
///    TaapdeelPerfBenchmark.end('probe_explore');
///
/// 4️⃣ في نهاية _reloadHomeSections:
///    TaapdeelPerfBenchmark.end('home_init');
///    TaapdeelPerfBenchmark.printReport();
///
/// =====================================================
/// مثال Output في الـ console:
/// =====================================================
/// ✅ [probe_explore] 62ms       ← بعد الـ fix (parallel)
/// 🔴 [probe_explore] 480ms      ← قبل الـ fix (sequential)
///
/// === Taapdeel Perf Report ===
/// ✅  probe_explore
///    avg=62ms  min=55ms  max=71ms  (n=3)
///    [███░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 62ms
/// ============================
