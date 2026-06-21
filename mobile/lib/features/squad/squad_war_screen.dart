// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme_colors.dart';

class SquadWarScreen extends StatefulWidget {
  final ApiService apiService;
  const SquadWarScreen({super.key, required this.apiService});

  @override
  State<SquadWarScreen> createState() => _SquadWarScreenState();
}

class _SquadWarScreenState extends State<SquadWarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _currentWar;
  List<Map<String, dynamic>> _history = [];
  bool _loadingCurrent = true;
  bool _loadingHistory = true;
  bool _historyLoaded = false;
  bool _usingMockData = false;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_historyLoaded) _loadHistory();
    });
    _loadCurrent();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0 && mounted) {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrent() async {
    setState(() => _loadingCurrent = true);
    try {
      final data = await widget.apiService.fetchCurrentWar();
      final remainingMs = (data['timeRemainingMs'] as num?)?.toInt() ?? 0;
      if (mounted) {
        setState(() {
          _currentWar = data;
          _remaining = Duration(milliseconds: remainingMs);
          _loadingCurrent = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentWar = _mockCurrentWar();
          _remaining = const Duration(days: 3, hours: 6, minutes: 12);
          _loadingCurrent = false;
          _usingMockData = true;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final data = await widget.apiService.fetchSquadWarHistory();
      if (mounted) {
        setState(() {
          _history = data.isEmpty ? _mockHistory() : data;
          _loadingHistory = false;
          _historyLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _history = _mockHistory();
          _loadingHistory = false;
          _historyLoaded = true;
          _usingMockData = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: const Text(
          'SQUAD WAR',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.outline,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'JORIY JANG'),
            Tab(text: 'TARIX'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_usingMockData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.outlineVariant,
              child: Row(
                children: const [
                  Icon(Icons.cloud_off, color: AppColors.outline, size: 16),
                  SizedBox(width: 8),
                  Text("Oflayn rejim — namuna ma'lumotlari", style: TextStyle(color: AppColors.outline, fontSize: 12)),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Current war tab ──────────────────────────────────────────────────────

  Widget _buildCurrentTab() {
    if (_loadingCurrent) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final war = _currentWar;
    if (war == null) return _buildEmpty("Hozircha jang yo'q");

    final participants = (war['participants'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCountdownCard(),
        const SizedBox(height: 20),
        const Text(
          "JAMOALAR REYTINGI",
          style: TextStyle(color: AppColors.outline, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        if (participants.isEmpty)
          _buildEmpty("Hali ishtirokchi jamoalar yo'q")
        else
          ...participants.map((p) => _SquadWarRow(data: p)),
      ],
    );
  }

  Widget _buildCountdownCard() {
    final d = _remaining;
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                "HAFTALIK SQUAD WAR",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Eng ko'p km yugurgan jamoa g'olib bo'ladi!",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountdownBox(value: days, label: 'KUN'),
              const _CountdownSeparator(),
              _CountdownBox(value: hours, label: 'SOAT'),
              const _CountdownSeparator(),
              _CountdownBox(value: minutes, label: 'DAQ'),
              const _CountdownSeparator(),
              _CountdownBox(value: seconds, label: 'SON'),
            ],
          ),
        ],
      ),
    );
  }

  // ── History tab ──────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_history.isEmpty) return _buildEmpty("Hali tugagan janglar yo'q");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (_, i) => _WarHistoryCard(data: _history[i]),
    );
  }

  Widget _buildEmpty(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.outline, size: 48),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: AppColors.outline, fontSize: 14)),
        ],
      ),
    ),
  );

  // ── Mock data ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _mockCurrentWar() => {
    'participants': [
      {'rank': 1, 'name': 'Shadow Runners', 'tag': 'SR', 'color': '#7C3AED', 'score': 84.6},
      {'rank': 2, 'name': 'Nova Squad', 'tag': 'NS', 'color': '#2563EB', 'score': 71.2},
      {'rank': 3, 'name': 'Storm Force', 'tag': 'SF', 'color': '#059669', 'score': 58.9},
    ],
  };

  List<Map<String, dynamic>> _mockHistory() => [
    {
      'id': '1',
      'startDate': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      'endDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'winner': {'name': 'Shadow Runners', 'tag': 'SR', 'color': '#7C3AED'},
      'participants': [
        {'rank': 1, 'name': 'Shadow Runners', 'tag': 'SR', 'color': '#7C3AED', 'score': 96.4},
        {'rank': 2, 'name': 'Nova Squad', 'tag': 'NS', 'color': '#2563EB', 'score': 80.1},
        {'rank': 3, 'name': 'Storm Force', 'tag': 'SF', 'color': '#059669', 'score': 65.3},
      ],
    },
  ];
}

// ── Countdown widgets ────────────────────────────────────────────────────────

class _CountdownBox extends StatelessWidget {
  final int value;
  final String label;
  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Montserrat'),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  const _CountdownSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(':', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w800, fontSize: 20)),
    );
  }
}

// ── Squad war row ─────────────────────────────────────────────────────────────

class _SquadWarRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SquadWarRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.tryParse((data['color'] as String? ?? '#ADC6FF').replaceFirst('#', '0xFF')) ?? 0xFFADC6FF);
    final name = data['name'] as String? ?? 'Squad';
    final tag = data['tag'] as String? ?? '';
    final score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final rank = data['rank'] as int? ?? 0;
    final medals = ['🥇', '🥈', '🥉'];
    final isMedal = rank >= 1 && rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMedal ? color.withOpacity(0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMedal ? color.withOpacity(0.35) : AppColors.outlineVariant,
          width: isMedal ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              isMedal ? medals[rank - 1] : '$rank',
              style: const TextStyle(fontSize: 18, color: AppColors.outline, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                tag.isNotEmpty ? tag.substring(0, tag.length.clamp(0, 2)) : (name.isNotEmpty ? name[0] : 'S'),
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Text('${score.toStringAsFixed(1)} km', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
        ],
      ),
    );
  }
}

// ── War history card ─────────────────────────────────────────────────────────

class _WarHistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WarHistoryCard({required this.data});

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final winner = data['winner'] as Map<String, dynamic>?;
    final participants = (data['participants'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final winnerColor = Color(int.tryParse(((winner?['color'] as String?) ?? '#FFD700').replaceFirst('#', '0xFF')) ?? 0xFFFFD700);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatDate(data['startDate'] as String?)} — ${_formatDate(data['endDate'] as String?)}',
            style: const TextStyle(color: AppColors.outline, fontSize: 11),
          ),
          const SizedBox(height: 10),
          if (winner != null)
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${winner['name']} g'olib bo'ldi!",
                    style: TextStyle(color: winnerColor, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ],
            )
          else
            const Text("G'olib aniqlanmadi", style: TextStyle(color: AppColors.outline, fontSize: 13)),
          const SizedBox(height: 12),
          ...participants.take(3).map((p) {
            final color = Color(int.tryParse((p['color'] as String? ?? '#ADC6FF').replaceFirst('#', '0xFF')) ?? 0xFFADC6FF);
            final score = (p['score'] as num?)?.toDouble() ?? 0.0;
            final rank = p['rank'] as int? ?? 0;
            final medals = ['🥇', '🥈', '🥉'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(rank >= 1 && rank <= 3 ? medals[rank - 1] : '$rank', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(p['name'] as String? ?? '', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                  ),
                  Text('${score.toStringAsFixed(1)} km', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
