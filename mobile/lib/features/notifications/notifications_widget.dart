import 'package:flutter/material.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = const [
      {
        'title': 'New contested zone',
        'message': 'Move quickly to take control of the red sector.',
        'time': '2m ago',
      },
      {
        'title': 'Rank boost',
        'message': 'You climbed to #4 on the weekly leaderboard.',
        'time': '20m ago',
      },
      {
        'title': 'Premium trial',
        'message': 'Unlock premium analytics for your next match.',
        'time': '1h ago',
      },
    ];

    return Container(
      color: const Color(0xFF071220),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Icon(Icons.notifications_active, color: Color(0xFF7B92FF)),
                SizedBox(width: 10),
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B33),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A3B61)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['message']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['time']!,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
