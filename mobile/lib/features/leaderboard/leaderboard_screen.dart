// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../api_service.dart';
import '../../theme_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  final ApiService? apiService;

  const LeaderboardScreen({super.key, this.apiService});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  String? _error;

  static const List<Map<String, dynamic>> _mockData = [
    {
      'rank': 1,
      'username': 'ShadowRunner',
      'territoryCount': 48,
      'xp': 3480,
      'level': 12,
      'isPremium': true,
    },
    {
      'rank': 2,
      'username': 'NovaPulse',
      'territoryCount': 40,
      'xp': 3020,
      'level': 10,
      'isPremium': false,
    },
    {
      'rank': 3,
      'username': 'Vortex',
      'territoryCount': 36,
      'xp': 2850,
      'level': 9,
      'isPremium': true,
    },
    {
      'rank': 4,
      'username': 'EchoStorm',
      'territoryCount': 28,
      'xp': 2410,
      'level': 8,
      'isPremium': false,
    },
    {
      'rank': 5,
      'username': 'Horizon',
      'territoryCount': 24,
      'xp': 2110,
      'level': 7,
      'isPremium': false,
    },
    {
      'rank': 6,
      'username': 'CyberWolf',
      'territoryCount': 20,
      'xp': 1870,
      'level': 6,
      'isPremium': false,
    },
    {
      'rank': 7,
      'username': 'Phantom',
      'territoryCount': 18,
      'xp': 1650,
      'level': 6,
      'isPremium': false,
    },
    {
      'rank': 8,
      'username': 'IronStride',
      'territoryCount': 15,
      'xp': 1420,
      'level': 5,
      'isPremium': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.apiService != null) {
        final data = await widget.apiService!.fetchLeaderboard();
        setState(() => _entries = data);
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() => _entries = _mockData);
      }
    } catch (_) {
      setState(() => _entries = _mockData);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_entries.length >= 3) _buildPodium(),
            Expanded(
              child: _isLoading ? _buildShimmer() : _buildList(),
            ),
            if (!_isLoading && _entries.isNotEmpty) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REYTING',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                'Haftalik musobaqa',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _loadLeaderboard,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    if (_entries.length < 3) return const SizedBox.shrink();
    final first = _entries[0];
    final second = _entries[1];
    final third = _entries[2];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainerLow.withOpacity(0.8),
            AppColors.surfaceContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumEntry(
            entry: second,
            rank: 2,
            medalColor: const Color(0xFFB0B7C3),
            size: 60,
            height: 70,
          ),
          _PodiumEntry(
            entry: first,
            rank: 1,
            medalColor: const Color(0xFFFFD700),
            size: 74,
            height: 100,
            showCrown: true,
          ),
          _PodiumEntry(
            entry: third,
            rank: 3,
            medalColor: const Color(0xFFCD7F32),
            size: 60,
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final rest = _entries.skip(3).toList();
    if (rest.isEmpty) {
      return _entries.isEmpty
          ? const Center(
              child: Text(
                'Ma\'lumot topilmadi',
                style: TextStyle(color: AppColors.outline),
              ),
            )
          : const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: rest.length,
      itemBuilder: (context, index) {
        final entry = rest[index];
        final rank = entry['rank'] as int? ?? index + 4;
        return _LeaderboardRow(entry: entry, rank: rank);
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerLow,
      highlightColor: AppColors.surfaceContainerHigh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    // Show current user's approximate rank at bottom
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4DFE6B00),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Sizning o\'rningiz',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '#${_entries.length + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumEntry extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int rank;
  final Color medalColor;
  final double size;
  final double height;
  final bool showCrown;

  const _PodiumEntry({
    required this.entry,
    required this.rank,
    required this.medalColor,
    required this.size,
    required this.height,
    this.showCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    final username = entry['username'] as String? ?? 'User';
    final xp = entry['xp'] as int? ?? 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCrown)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24),
        const SizedBox(height: 4),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [medalColor.withOpacity(0.3), medalColor.withOpacity(0.1)],
            ),
            border: Border.all(color: medalColor, width: 2.5),
          ),
          child: Center(
            child: Text(
              username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: medalColor,
                fontSize: size * 0.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          username.length > 8 ? '${username.substring(0, 8)}..' : username,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$xp pts',
          style: TextStyle(color: medalColor, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Container(
          width: size + 10,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: medalColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int rank;

  const _LeaderboardRow({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    final username = entry['username'] as String? ?? 'User';
    final xp = entry['xp'] as int? ?? 0;
    final territoryCount = entry['territoryCount'] as int? ?? 0;
    final isPremium = entry['isPremium'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: AppColors.outline,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Text(
              username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: Color(0xFFFFD700),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$territoryCount hudud',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
