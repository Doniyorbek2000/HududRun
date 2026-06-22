// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme_colors.dart';

class RunHistoryScreen extends StatefulWidget {
  final ApiService apiService;
  const RunHistoryScreen({super.key, required this.apiService});

  @override
  State<RunHistoryScreen> createState() => _RunHistoryScreenState();
}

class _RunHistoryScreenState extends State<RunHistoryScreen> {
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;

  // Computed stats
  double get _totalKm => _activities.fold(0.0, (s, a) => s + ((a['distance'] as num?)?.toDouble() ?? 0));
  int get _totalRuns => _activities.length;
  int get _totalSeconds => _activities.fold(0, (s, a) => s + ((a['duration'] as num?)?.toInt() ?? 0));
  double get _bestRun => _activities.isEmpty ? 0 : _activities.map((a) => (a['distance'] as num?)?.toDouble() ?? 0).reduce((a, b) => a > b ? a : b);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.apiService.fetchActivities();
      if (mounted) setState(() { _activities = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _activities = _mockActivities(); _loading = false; });
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}s ${m}d';
    return '${m}d';
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
  }

  String _pace(double km, int sec) {
    if (km <= 0) return '--';
    final paceMin = (sec / 60) / km;
    final m = paceMin.toInt();
    final s = ((paceMin - m) * 60).toInt();
    return "$m:${s.toString().padLeft(2,'0')}/km";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: const Text('YUGURISH TARIXI',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _activities.isEmpty
              ? _buildEmpty()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    _buildWeekChart(),
                    const SizedBox(height: 16),
                    const Text('BARCHA YUGURISHLAR',
                      style: TextStyle(color: AppColors.outline, fontSize: 11, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    ..._activities.asMap().entries.map((e) => _buildActivityCard(e.value, e.key == 0)),
                  ],
                ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x33ADC6FF), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBox(label: 'Jami km', value: _totalKm.toStringAsFixed(1), icon: Icons.route, color: AppColors.primary),
              _StatBox(label: 'Yugurishlar', value: '$_totalRuns', icon: Icons.directions_run, color: AppColors.secondary),
              _StatBox(label: 'Vaqt', value: _formatDuration(_totalSeconds), icon: Icons.timer_outlined, color: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.outlineVariant),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBox(label: "Eng yaxshi", value: '${_bestRun.toStringAsFixed(2)} km', icon: Icons.emoji_events_outlined, color: const Color(0xFFFFD700)),
              _StatBox(label: "O'rtacha", value: _totalRuns > 0 ? '${(_totalKm / _totalRuns).toStringAsFixed(2)} km' : '0', icon: Icons.bar_chart, color: const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekChart() {
    // Last 7 days bar chart
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    final dayLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

    final Map<String, double> dayDist = {};
    for (final a in _activities) {
      final dateStr = a['startTime'] as String? ?? a['createdAt'] as String? ?? '';
      final d = DateTime.tryParse(dateStr);
      if (d == null) continue;
      final key = DateTime(d.year, d.month, d.day).toIso8601String();
      dayDist[key] = (dayDist[key] ?? 0) + ((a['distance'] as num?)?.toDouble() ?? 0);
    }

    final values = days.map((d) => dayDist[d.toIso8601String()] ?? 0.0).toList();
    final maxVal = values.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BU HAFTA', style: TextStyle(color: AppColors.outline, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final val = values[i];
                final ratio = maxVal > 0 ? val / maxVal : 0.0;
                final isToday = i == 6;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (val > 0)
                          Text('${val.toStringAsFixed(1)}', style: const TextStyle(color: AppColors.outline, fontSize: 8)),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: (ratio * 60).clamp(4.0, 60.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isToday
                                  ? [const Color(0xFFFE6B00), const Color(0xFFFFB347)]
                                  : [AppColors.primary.withOpacity(0.6), AppColors.primary],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dayLabels[DateTime.now().subtract(Duration(days: 6 - i)).weekday % 7],
                          style: TextStyle(
                            color: isToday ? AppColors.secondary : AppColors.outline,
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> a, bool isLatest) {
    final km = (a['distance'] as num?)?.toDouble() ?? 0;
    final dur = (a['duration'] as num?)?.toInt() ?? 0;
    final date = _formatDate(a['startTime'] as String? ?? a['createdAt'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLatest ? AppColors.primary.withOpacity(0.07) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant,
          width: isLatest ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isLatest ? AppColors.primary : AppColors.outline).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_run,
              color: isLatest ? AppColors.primary : AppColors.outline, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${km.toStringAsFixed(2)} km',
                      style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 15)),
                    if (isLatest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('YANGI', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                Text('$date • ${_formatDuration(dur)} • ${_pace(km, dur)}',
                  style: const TextStyle(color: AppColors.outline, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${(km * 20).toInt()} XP',
                style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_run, color: AppColors.outline, size: 64),
        SizedBox(height: 16),
        Text('Hali yugurishlar yo\'q', style: TextStyle(color: AppColors.outline, fontSize: 16)),
      ],
    ),
  );

  List<Map<String, dynamic>> _mockActivities() => [
    {'distance': 5.2, 'duration': 1800, 'startTime': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
    {'distance': 3.8, 'duration': 1320, 'startTime': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
    {'distance': 7.1, 'duration': 2580, 'startTime': DateTime.now().subtract(const Duration(days: 5)).toIso8601String()},
    {'distance': 4.5, 'duration': 1560, 'startTime': DateTime.now().subtract(const Duration(days: 7)).toIso8601String()},
  ];
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 10)),
      ],
    );
  }
}
