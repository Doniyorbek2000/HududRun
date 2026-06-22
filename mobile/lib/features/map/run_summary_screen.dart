// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../theme_colors.dart';

class RunSummaryScreen extends StatelessWidget {
  final double distanceKm;
  final int durationSeconds;
  final int caloriesBurned;
  final int territoriesCaptured;
  final int pointsEarned;
  final String? newAchievement;
  final DateTime startTime;
  final DateTime endTime;
  final VoidCallback? onShare;
  final VoidCallback? onHome;

  const RunSummaryScreen({
    super.key,
    required this.distanceKm,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.territoriesCaptured,
    required this.pointsEarned,
    required this.startTime,
    required this.endTime,
    this.newAchievement,
    this.onShare,
    this.onHome,
  });

  String get _formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedPace {
    if (distanceKm <= 0) return '--:--';
    final paceSeconds = durationSeconds / distanceKm;
    final m = paceSeconds ~/ 60;
    final s = (paceSeconds % 60).round();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 24),

              // Distance card
              _buildDistanceCard(),
              const SizedBox(height: 16),

              // Stats grid
              _buildStatsGrid(),
              const SizedBox(height: 16),

              // Territories section
              if (territoriesCaptured > 0) ...[
                _buildTerritoriesSection(),
                const SizedBox(height: 16),
              ],

              // Rewards section
              _buildRewardsSection(),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.tertiary, size: 16),
              const SizedBox(width: 6),
              const Text(
                'YUGURISH YAKUNLANDI',
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A00), Color(0xFF201F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryContainer.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryContainer.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distanceKm.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 6),
                child: Text(
                  'km',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Bosib o\'tilgan masofa',
            style: TextStyle(color: AppColors.outline, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Vaqt',
                  value: _formattedDuration,
                  icon: Icons.timer_outlined,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.outlineVariant),
              Expanded(
                child: _StatItem(
                  label: 'Temp',
                  value: '$_formattedPace/km',
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _GlassStatCard(
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFFE6B00),
            value: '$caloriesBurned',
            label: 'Kaloriya',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassStatCard(
            icon: Icons.flag_outlined,
            iconColor: AppColors.tertiary,
            value: '$territoriesCaptured',
            label: 'Hududlar',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassStatCard(
            icon: Icons.star_outline,
            iconColor: AppColors.primary,
            value: '+$pointsEarned',
            label: 'Ballar',
          ),
        ),
      ],
    );
  }

  Widget _buildTerritoriesSection() {
    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: AppColors.tertiary, size: 18),
              const SizedBox(width: 8),
              Text(
                '$territoriesCaptured ta yangi hudud egallandi',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, color: AppColors.outline, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Xarita ko\'rinishi',
                    style: TextStyle(color: AppColors.outline, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mukofotlar',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+$pointsEarned ball',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (newAchievement != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFFFD700),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            newAchievement!,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Share button - outline style
        GestureDetector(
          onTap: onShare ?? () {},
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_outlined, color: AppColors.onSurface, size: 18),
                SizedBox(width: 8),
                Text(
                  'Natijani ulashish',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Home button - green glow style
        GestureDetector(
          onTap: onHome ?? () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x662AE500),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'ASOSIY EKRANGA QAYTISH',
                style: TextStyle(
                  color: AppColors.onTertiary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.outline, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.outline, fontSize: 11),
        ),
      ],
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _GlassStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}
