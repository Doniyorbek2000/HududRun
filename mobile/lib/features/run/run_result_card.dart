// ignore_for_file: deprecated_member_use
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../theme_colors.dart';

class RunResultCard extends StatefulWidget {
  final double distanceKm;
  final int durationSeconds;
  final int territoriesCaptured;
  final int xpEarned;
  final String username;
  final int streak;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const RunResultCard({
    super.key,
    required this.distanceKm,
    required this.durationSeconds,
    required this.territoriesCaptured,
    required this.xpEarned,
    required this.username,
    required this.streak,
    required this.onShare,
    required this.onClose,
  });

  @override
  State<RunResultCard> createState() => _RunResultCardState();
}

class _RunResultCardState extends State<RunResultCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _pace(double distKm, int durSec) {
    if (distKm <= 0) return '--:--';
    final paceSecPerKm = durSec / distKm;
    final m = paceSecPerKm ~/ 60;
    final s = paceSecPerKm % 60;
    return '${m.toInt()}:${s.toInt().toString().padLeft(2, '0')}/km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The shareable card
                RepaintBoundary(
                  key: _cardKey,
                  child: _buildCard(),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionBtn(
                      icon: Icons.close,
                      label: 'Yopish',
                      color: AppColors.outline,
                      onTap: widget.onClose,
                    ),
                    const SizedBox(width: 16),
                    _ActionBtn(
                      icon: Icons.share_outlined,
                      label: 'Ulashish',
                      color: AppColors.tertiary,
                      onTap: widget.onShare,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131313), Color(0xFF1E1E1E)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FE6B00),
            blurRadius: 40,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_run, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HUDUDRUN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Text(
                    '@${widget.username}',
                    style: const TextStyle(color: AppColors.outline, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              if (widget.streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🔥 ${widget.streak}',
                    style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Main stat: distance
          Text(
            '${widget.distanceKm.toStringAsFixed(2)} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat',
              height: 1,
            ),
          ),
          Text(
            _pace(widget.distanceKm, widget.durationSeconds),
            style: const TextStyle(color: AppColors.outline, fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Stats grid
          Row(
            children: [
              _CardStat(
                label: 'VAQT',
                value: _formatDuration(widget.durationSeconds),
                icon: Icons.timer_outlined,
                color: AppColors.primary,
              ),
              _CardStat(
                label: 'HUDUDLAR',
                value: '${widget.territoriesCaptured}',
                icon: Icons.map_outlined,
                color: AppColors.secondary,
              ),
              _CardStat(
                label: 'XP',
                value: '+${widget.xpEarned}',
                icon: Icons.star_outline,
                color: AppColors.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Victory banner if territories captured
          if (widget.territoriesCaptured > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🏆 ${widget.territoriesCaptured} hudud egallandi!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.outline,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
