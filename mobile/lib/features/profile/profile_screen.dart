import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../models/user.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final ApiService? apiService;

  const ProfileScreen({super.key, required this.user, this.apiService});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF081520),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF304E98),
            child: Icon(Icons.run_circle, size: 42, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            user.username,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.isPremium ? 'Premium Runner' : 'Rookie Runner',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _StatTile(label: 'Territory owned', value: '6 km²'),
          _StatTile(label: 'XP', value: user.xp.toString()),
          _StatTile(label: 'Level', value: user.level.toString()),
          const SizedBox(height: 16),
          _TerritoryStatsCard(),
          const SizedBox(height: 16),
          const _BadgeRow(),
          const SizedBox(height: 24),
          const _InfoCard(
            title: 'Active mission',
            description:
                'Secure contested zone near your current path to earn bonus XP and power.',
            icon: Icons.track_changes,
          ),
          const SizedBox(height: 16),
          const _InfoCard(
            title: 'Match history',
            description:
                'Last run: +2.1 km² territory, 860 XP, 1st place in zone challenge.',
            icon: Icons.history,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E436C)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D34),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Badges',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _BadgeChip(
                label: 'Territory Ace',
                icon: Icons.flag,
                color: Color(0xFF7B92FF),
              ),
              _BadgeChip(
                label: 'Speed Runner',
                icon: Icons.speed,
                color: Color(0xFF4CD6A9),
              ),
              _BadgeChip(
                label: 'Guardian',
                icon: Icons.shield,
                color: Color(0xFFEF9A5B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _BadgeChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF162645),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TerritoryStatsCard extends StatelessWidget {
  const _TerritoryStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E436C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Territory Stats',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TerritoryStatItem(label: 'Hududlar', value: '0 hudud'),
              _TerritoryStatItem(label: 'Maydon', value: '0.0 km²'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TerritoryStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _TerritoryStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A3A5D)),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF304E98),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
