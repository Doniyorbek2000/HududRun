import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF081320),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1A2F),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A3A5D)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HududRun Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock exclusive territory boosts, deeper analytics and event access.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Color(0xFFFFC94A)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Faster territory capture speed',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Color(0xFF7B92FF)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detailed performance analytics',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFF4CD6A9)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Premium missions and rewards',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C7BFF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Upgrade now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Top premium rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _RewardTile(
            title: 'Double XP streak',
            subtitle: 'Keep your streak alive to earn double experience.',
            icon: Icons.whatshot,
          ),
          _RewardTile(
            title: 'Elite territory banners',
            subtitle: 'Display your status with exclusive map banners.',
            icon: Icons.flag,
          ),
          _RewardTile(
            title: 'Event access',
            subtitle: 'Join premium battles and territory tournaments.',
            icon: Icons.workspace_premium,
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _RewardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3A5D)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B2A52),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: const Color(0xFF7B92FF), size: 26),
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
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
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
