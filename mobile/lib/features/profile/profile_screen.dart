// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../models/user.dart';
import '../../theme_colors.dart';
import '../../l10n/countries.dart';
import '../friends/friends_screen.dart';
import '../run/run_history_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final ApiService? apiService;

  const ProfileScreen({super.key, required this.user, this.apiService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  Map<String, dynamic>? _territoryStats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadTerritoryStats();
  }

  Future<void> _loadTerritoryStats() async {
    if (widget.apiService == null) {
      setState(() => _loadingStats = false);
      return;
    }
    try {
      final response = await widget.apiService!
          .fetchTerritoryStats();
      setState(() {
        _territoryStats = response;
        _loadingStats = false;
      });
    } catch (_) {
      setState(() => _loadingStats = false);
    }
  }

  void _onProfileUpdated(Map<String, dynamic> data) {
    setState(() {
      _user = User(
        id: data['id'] as String? ?? _user.id,
        username: data['username'] as String? ?? _user.username,
        phone: data['phone'] as String? ?? _user.phone,
        avatar: data['avatar'] as String? ?? _user.avatar,
        country: data['country'] as String? ?? _user.country,
        bio: data['bio'] as String? ?? _user.bio,
        level: data['level'] as int? ?? _user.level,
        xp: data['xp'] as int? ?? _user.xp,
        isPremium: data['isPremium'] as bool? ?? _user.isPremium,
        createdAt: _user.createdAt,
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // ── Avatar + name + country ──────────────────────────────────────
          Center(
            child: _AvatarWidget(user: _user),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _user.username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
              if (_user.country != null) ...[
                const SizedBox(width: 8),
                Text(
                  countryFlag(_user.country),
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ],
          ),
          if (_user.bio != null && _user.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _user.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _user.isPremium ? 'Premium Runner' : 'Rookie Runner',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.outline, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // ── Edit profile button ──────────────────────────────────────────
          if (widget.apiService != null)
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        user: _user,
                        apiService: widget.apiService!,
                        onUpdated: _onProfileUpdated,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Profilni tahrirlash'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ── Stats row ────────────────────────────────────────────────────
          _StatsRow(
            territoryCount: _loadingStats
                ? null
                : (_territoryStats?['count'] as int?),
            totalAreaKm2: _loadingStats
                ? null
                : (_territoryStats?['totalAreaKm2'] as num?)?.toDouble(),
            xp: _user.xp,
            level: _user.level,
          ),
          const SizedBox(height: 20),

          // ── Badges ───────────────────────────────────────────────────────
          const _BadgeRow(),
          const SizedBox(height: 20),

          // ── Info cards ───────────────────────────────────────────────────
          if (widget.apiService != null) ...[
            _InfoCard(
              title: "Do'stlar",
              description: "Do'stlaringizni ko'ring va yangi do'stlar qo'shing.",
              icon: Icons.people_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendsScreen(apiService: widget.apiService!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Yugurish tarixi',
              description:
                  "O'tgan yugurishlaringiz, statistikangiz va haftalik grafikni ko'ring.",
              icon: Icons.history,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RunHistoryScreen(apiService: widget.apiService!),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const _InfoCard(
            title: 'Active mission',
            description:
                'Secure contested zone near your current path to earn bonus XP and power.',
            icon: Icons.track_changes,
          ),
        ],
      ),
    );
  }
}

// ── Avatar widget ──────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final User user;
  const _AvatarWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      try {
        final data = user.avatar!.contains(',')
            ? user.avatar!.split(',').last
            : user.avatar!;
        image = MemoryImage(base64Decode(data));
      } catch (_) {
        image = null;
      }
    }

    return CircleAvatar(
      radius: 54,
      backgroundColor: AppColors.surfaceContainerHigh,
      backgroundImage: image,
      child: image == null
          ? Text(
              user.username.isNotEmpty
                  ? user.username[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int? territoryCount;
  final double? totalAreaKm2;
  final int xp;
  final int level;

  const _StatsRow({
    required this.territoryCount,
    required this.totalAreaKm2,
    required this.xp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Hududlar',
            value: territoryCount != null ? '$territoryCount' : '—',
            icon: Icons.map_outlined,
          ),
          _Divider(),
          _StatItem(
            label: 'km²',
            value: totalAreaKm2 != null
                ? totalAreaKm2!.toStringAsFixed(1)
                : '—',
            icon: Icons.straighten_outlined,
          ),
          _Divider(),
          _StatItem(
            label: 'XP',
            value: '$xp',
            icon: Icons.bolt_outlined,
          ),
          _Divider(),
          _StatItem(
            label: 'Daraja',
            value: '$level',
            icon: Icons.military_tech_outlined,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.outlineVariant,
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
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
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
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Badges',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
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
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: card,
    );
  }
}
