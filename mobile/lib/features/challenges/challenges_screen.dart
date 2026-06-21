// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme_colors.dart';

class ChallengesScreen extends StatefulWidget {
  final ApiService? apiService;

  const ChallengesScreen({super.key, this.apiService});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  static const _defaultChallenges = [
    {
      'title': '7 kunlik marafon',
      'time': 'Qolgan vaqt: 2 kun 14s',
      'progress': 0.65,
      'progressLabel': '65%',
      'reward': 'Elite Badge + 500 Pts',
      'color': 0xFFADC6FF,
      'hot': false,
    },
    {
      'title': 'Hudud qiroli',
      'time': 'Qolgan vaqt: 18s 45m',
      'progress': 0.6,
      'progressLabel': '3/5 Hudud',
      'reward': '1200 Pts + King Title',
      'color': 0xFF2AE500,
      'hot': true,
    },
  ];

  List<Map<String, dynamic>> _challenges =
      List<Map<String, dynamic>>.from(_defaultChallenges);
  bool _loadingChallenges = false;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    if (widget.apiService == null) return;
    setState(() => _loadingChallenges = true);
    try {
      final data = await widget.apiService!.fetchChallenges();
      if (data.isNotEmpty) {
        final apiChallenges = data.map((c) => <String, dynamic>{
              'title': c['title'] ?? 'Musobaqa',
              'time': 'Qolgan: ${c['endDate'] ?? '?'}',
              'progress':
                  ((c['progress'] ?? 0) as num).toDouble() / 100.0,
              'progressLabel': '${c['progress'] ?? 0}%',
              'reward': '${c['target'] ?? 0} ${c['type'] ?? ''}',
              'color': 0xFFADC6FF,
              'hot': false,
            }).toList();
        if (mounted) {
          setState(() => _challenges = apiChallenges);
        }
      }
    } catch (_) {
      // fallback: keep mock data
    } finally {
      if (mounted) setState(() => _loadingChallenges = false);
    }
  }

  static const _milestones = [
    {
      'title': '100 KM MASOFA',
      'desc': 'Mavsum davomida jami 100 km masofani bosib o\'ting.',
      'current': 92,
      'target': 100,
      'unit': 'km',
      'done': false,
      'color': 0xFFADC6FF,
    },
    {
      'title': 'TUNGI OVCHI',
      'desc': 'Soat 22:00 dan keyin 5 marta 5km+ yugurish.',
      'locked': true,
      'color': 0xFF8B90A0,
    },
    {
      'title': 'JAMOA SARDORI',
      'desc': 'Guruhdagi 10 ta do\'stingiz bilan musobaqa uyushtiring.',
      'current': 7,
      'target': 10,
      'unit': 'do\'st',
      'done': false,
      'color': 0xFF2AE500,
    },
  ];

  static const _friends = [
    {'name': 'Zarina', 'status': 'Hozir yugurmoqda', 'online': true},
    {'name': 'Jaloliddin', 'status': 'Offline', 'online': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.9),
        title: const Text(
          'MUSOBAQALAR',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: AppColors.primary),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // ── Faol musobaqalar ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Faol Musobaqalar',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface)),
              Text('Barchasi',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          if (_loadingChallenges)
            const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _challenges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final c = _challenges[i];
                final color = Color(c['color'] as int);
                return _ChallengeCard(
                  title: c['title'] as String,
                  time: c['time'] as String,
                  progress: c['progress'] as double,
                  progressLabel: c['progressLabel'] as String,
                  reward: c['reward'] as String,
                  color: color,
                  isHot: c['hot'] as bool,
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          // ── Yutuqlar yo'li ─────────────────────────────────────────────
          const Text("Yutuqlar Yo'li",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          const SizedBox(height: 16),
          _MilestoneTimeline(milestones: _milestones),
          const SizedBox(height: 28),
          // ── Do'stlar bilan ────────────────────────────────────────────
          const Text("Do'stlar bilan",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          const SizedBox(height: 12),
          _GlassCard(
            child: Column(
              children: [
                ..._friends.map((f) => _FriendRow(
                      name: f['name'] as String,
                      status: f['status'] as String,
                      online: f['online'] as bool,
                    )),
                const Divider(
                    color: Color(0x0DFFFFFF), height: 1),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add,
                      color: AppColors.primary, size: 18),
                  label: const Text("Yangi do'stlar qidirish",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final String title, time, progressLabel, reward;
  final double progress;
  final Color color;
  final bool isHot;

  const _ChallengeCard({
    required this.title,
    required this.time,
    required this.progress,
    required this.progressLabel,
    required this.reward,
    required this.color,
    required this.isHot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.outline)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHot ? 'ISSIQ' : 'Aktiv',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jarayon',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant)),
              Text(progressLabel,
                  style:
                      TextStyle(fontSize: 11, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.military_tech,
                    color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Text(reward,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> milestones;
  const _MilestoneTimeline({required this.milestones});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: milestones.asMap().entries.map((e) {
        final m = e.value;
        final color = Color(m['color'] as int);
        final isLocked = m['locked'] == true;
        final double? current =
            m['current'] != null ? (m['current'] as int).toDouble() : null;
        final double? target =
            m['target'] != null ? (m['target'] as int).toDouble() : null;
        final progress = (current != null && target != null)
            ? (current / target).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainer,
                      border: Border.all(
                          color: isLocked
                              ? AppColors.outlineVariant.withOpacity(0.3)
                              : color.withOpacity(0.5),
                          width: 2),
                    ),
                    child: Icon(
                      isLocked
                          ? Icons.lock
                          : (e.key == 0
                              ? Icons.directions_run
                              : Icons.groups),
                      color: isLocked ? AppColors.outline : color,
                      size: 20,
                    ),
                  ),
                  if (e.key < milestones.length - 1)
                    Container(
                        width: 2,
                        height: 24,
                        color: Colors.white.withOpacity(0.08)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Opacity(
                  opacity: isLocked ? 0.5 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m['title'] as String,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                    letterSpacing: 0.3)),
                            if (isLocked)
                              const Icon(Icons.lock,
                                  color: AppColors.outline,
                                  size: 16)
                            else if (current != null)
                              Text(
                                '${current.toInt()}/${target!.toInt()} ${m['unit']}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(m['desc'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                height: 1.4)),
                        if (!isLocked && current != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor:
                                  AppColors.surfaceContainerHighest,
                              valueColor:
                                  AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final String name, status;
  final bool online;
  const _FriendRow(
      {required this.name, required this.status, required this.online});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  border: Border.all(
                      color: online
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.white.withOpacity(0.08)),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.onSurfaceVariant, size: 22),
              ),
              if (online)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.background, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
                Text(status,
                    style: TextStyle(
                        fontSize: 12,
                        color: online
                            ? AppColors.tertiary
                            : AppColors.outline)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: online
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surfaceContainer,
              shape: const StadiumBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: Text(
              online ? 'Taklif qilish' : 'Profil',
              style: TextStyle(
                  fontSize: 12,
                  color: online
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}
