import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = const [
      {
        'rank': '1',
        'name': 'ShadowRunner',
        'territory': '12 km²',
        'pts': '3,480',
      },
      {'rank': '2', 'name': 'NovaPulse', 'territory': '10 km²', 'pts': '3,020'},
      {'rank': '3', 'name': 'Vortex', 'territory': '9 km²', 'pts': '2,850'},
      {'rank': '4', 'name': 'EchoStorm', 'territory': '7 km²', 'pts': '2,410'},
      {'rank': '5', 'name': 'Horizon', 'territory': '6 km²', 'pts': '2,110'},
    ];

    return Container(
      color: const Color(0xFF081420),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: const Color(0xFF0D1A2D),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Weekly conquest',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Climb the global leaderboard by securing the most terrain and completing missions.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final item = leaderboard[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1628),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF2A3A5D)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF304C8C),
                      child: Text(
                        item['rank']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      item['territory']!,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Text(
                      item['pts']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
