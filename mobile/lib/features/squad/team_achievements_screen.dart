// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../theme_colors.dart';

class TeamAchievementsScreen extends StatelessWidget {
  const TeamAchievementsScreen({super.key});

  static const List<Map<String, dynamic>> _activeChallenges = [
    {
      'title': 'Shahar Qahramoni',
      'description': '50 ta hudud egallang',
      'progress': 0.72,
      'current': 36,
      'target': 50,
      'color': 0xFFADC6FF,
      'reward': 1500,
    },
    {
      'title': 'Jamoa Marafoni',
      'description': 'Birgalikda 200 km yuguring',
      'progress': 0.45,
      'current': 90,
      'target': 200,
      'color': 0xFF2AE500,
      'reward': 800,
    },
    {
      'title': 'Hujum Rejasi',
      'description': '10 ta raqib hududini oling',
      'progress': 0.3,
      'current': 3,
      'target': 10,
      'color': 0xFFFFB693,
      'reward': 600,
    },
  ];

  static const List<Map<String, dynamic>> _trophies = [
    {
      'title': 'Birinchi Zabt',
      'color': 0xFFFFD700,
      'icon': Icons.flag,
      'earned': true,
    },
    {
      'title': 'Tezlik Rekordi',
      'color': 0xFFADC6FF,
      'icon': Icons.speed,
      'earned': true,
    },
    {
      'title': 'Hududlar Qiroli',
      'color': 0xFF2AE500,
      'icon': Icons.public,
      'earned': false,
    },
    {
      'title': 'Ustoz',
      'color': 0xFFFFB693,
      'icon': Icons.school,
      'earned': false,
    },
  ];

  static const List<Map<String, dynamic>> _contributors = [
    {
      'name': 'ShadowRunner',
      'contribution': 42,
      'unit': 'km',
      'badge': '🥇',
    },
    {
      'name': 'NovaPulse',
      'contribution': 35,
      'unit': 'km',
      'badge': '🥈',
    },
    {
      'name': 'Vortex',
      'contribution': 28,
      'unit': 'km',
      'badge': '🥉',
    },
    {
      'name': 'EchoStorm',
      'contribution': 20,
      'unit': 'km',
      'badge': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: const Text(
          'JAMOA YUTUQLARI',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSquadHero(),
          const SizedBox(height: 20),
          _buildSectionTitle('Faol Musobaqalar'),
          const SizedBox(height: 12),
          _buildActiveChallengesGrid(),
          const SizedBox(height: 20),
          _buildSectionTitle('Yutuqlar Xonasi'),
          const SizedBox(height: 12),
          _buildTrophiesScroll(),
          const SizedBox(height: 20),
          _buildSectionTitle('Top Hissachilar'),
          const SizedBox(height: 12),
          _buildContributorsList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSquadHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryContainer.withOpacity(0.15),
            AppColors.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryContainer.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Squad emblem
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x4DFE6B00),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shadow Runners',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '4 a\'zo • Daraja 7',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  '#3',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SquadStat(label: 'Hududlar', value: '36'),
              _VertDivider(),
              _SquadStat(label: 'Yutuqlar', value: '12'),
              _VertDivider(),
              _SquadStat(label: 'Jami km', value: '215'),
              _VertDivider(),
              _SquadStat(label: 'Ballar', value: '8,420'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildActiveChallengesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _activeChallenges.length,
      itemBuilder: (context, index) {
        final c = _activeChallenges[index];
        final color = Color(c['color'] as int);
        final progress = (c['progress'] as double).clamp(0.0, 1.0);
        final current = c['current'] as int;
        final target = c['target'] as int;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c['title'] as String,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$current/$target',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '+${c['reward']} ball',
                    style: const TextStyle(
                      color: AppColors.outline,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrophiesScroll() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trophies.length,
        itemBuilder: (context, index) {
          final t = _trophies[index];
          final color = Color(t['color'] as int);
          final earned = t['earned'] as bool;
          final icon = t['icon'] as IconData;

          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: earned
                  ? color.withOpacity(0.1)
                  : const Color(0xFF1E1E1E).withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: earned
                    ? color.withOpacity(0.3)
                    : Colors.white.withOpacity(0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  earned ? icon : Icons.lock_outline,
                  color: earned ? color : AppColors.outline,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  t['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: earned ? AppColors.onSurface : AppColors.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContributorsList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: _contributors.asMap().entries.map((entry) {
          final index = entry.key;
          final c = entry.value;
          final isLast = index == _contributors.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      c['badge'] as String? ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name'] as String,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Hissa: ${c['contribution']} ${c['unit']}',
                            style: const TextStyle(
                              color: AppColors.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: AppColors.surfaceContainerHigh,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (c['contribution'] as int) / 42,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(color: Colors.white.withOpacity(0.05), height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SquadStat extends StatelessWidget {
  final String label;
  final String value;
  const _SquadStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.outline, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.outlineVariant,
    );
  }
}
