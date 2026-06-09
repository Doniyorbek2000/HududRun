// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../theme_colors.dart';

class StreakWidget extends StatelessWidget {
  final int streak;
  const StreakWidget({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    Color streakColor;
    if (streak >= 30) streakColor = const Color(0xFFFF4500); // legendary
    else if (streak >= 7) streakColor = const Color(0xFFFF8C00); // fire
    else streakColor = AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: streakColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: streakColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak >= 7 ? '🔥' : '⚡',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak kun',
            style: TextStyle(
              color: streakColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
