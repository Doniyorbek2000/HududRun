// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../theme_colors.dart';

class TrophyRoomScreen extends StatefulWidget {
  const TrophyRoomScreen({super.key});

  @override
  State<TrophyRoomScreen> createState() => _TrophyRoomScreenState();
}

class _TrophyRoomScreenState extends State<TrophyRoomScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _featuredController;
  late Animation<double> _featuredFloatAnim;
  late Animation<double> _featuredGlowAnim;

  int _selectedTab = 0;
  bool _isLoading = true;

  static const List<String> _tabs = ['Badjlar', 'Kuboklar', 'Maxsus', 'Mavsumiy'];

  static const List<Map<String, dynamic>> _trophies = [
    {
      'title': 'Birinchi Qadam',
      'description': '1 km yugurdingiz',
      'icon': Icons.directions_walk,
      'color': 0xFF2AE500,
      'earned': true,
      'type': 'badge',
      'rarity': 'Umumiy',
    },
    {
      'title': 'Hudud Egasi',
      'description': 'Birinchi hududni zabt etdingiz',
      'icon': Icons.flag,
      'color': 0xFFADC6FF,
      'earned': true,
      'type': 'badge',
      'rarity': 'Noyob',
    },
    {
      'title': 'Tezkor Yuguruvchi',
      'description': '5 km/soat tezlikda yuguring',
      'icon': Icons.flash_on,
      'color': 0xFFFFB693,
      'earned': true,
      'type': 'badge',
      'rarity': 'Umumiy',
    },
    {
      'title': 'Shahar G\'olibi',
      'description': '10 ta hudud egallang',
      'icon': Icons.location_city,
      'color': 0xFFFFD700,
      'earned': false,
      'type': 'trophy',
      'rarity': 'Epik',
    },
    {
      'title': 'Marafon Ruhi',
      'description': 'Jami 42 km yuguring',
      'icon': Icons.emoji_events,
      'color': 0xFFFFD700,
      'earned': false,
      'type': 'trophy',
      'rarity': 'Afsonaviy',
    },
    {
      'title': 'Kecha-Kunduz',
      'description': 'Oy ichida har kuni yuguring',
      'icon': Icons.wb_twilight,
      'color': 0xFF9C27B0,
      'earned': false,
      'type': 'special',
      'rarity': 'Maxsus',
    },
    {
      'title': 'Qish Yogiri',
      'description': 'Sovuqda 5 km yuguring',
      'icon': Icons.ac_unit,
      'color': 0xFF64B5F6,
      'earned': false,
      'type': 'seasonal',
      'rarity': 'Mavsumiy',
    },
    {
      'title': 'Yoz Qahramoni',
      'description': 'Yozda 50 km yuguring',
      'icon': Icons.wb_sunny,
      'color': 0xFFFF8F00,
      'earned': true,
      'type': 'seasonal',
      'rarity': 'Mavsumiy',
    },
  ];

  int get _earnedCount => _trophies.where((t) => t['earned'] as bool).length;
  int get _totalCount => _trophies.length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });

    _featuredController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _featuredFloatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _featuredController, curve: Curves.easeInOut),
    );
    _featuredGlowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _featuredController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _featuredController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTrophies {
    const typeMap = ['badge', 'trophy', 'special', 'seasonal'];
    if (_selectedTab >= typeMap.length) return _trophies;
    final type = typeMap[_selectedTab];
    return _trophies.where((t) => t['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildFeaturedTrophy()),
            SliverToBoxAdapter(child: _buildTabBar()),
            SliverToBoxAdapter(child: _buildSeasonalProgress()),
            _buildTrophyGrid(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YUTUQLARIM',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Natijalaringiz tarixi',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 6),
                Text(
                  '$_earnedCount/$_totalCount',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.star,
              iconColor: AppColors.primary,
              value: '2,850',
              label: 'Jami ballar',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.military_tech,
              iconColor: const Color(0xFFFFD700),
              value: 'Daraja 8',
              label: 'Hozirgi daraja',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTrophy() {
    if (_trophies.isEmpty) return const SizedBox.shrink();
    final featured = _trophies.firstWhere(
      (t) => t['earned'] as bool && t['rarity'] != 'Umumiy',
      orElse: () => _trophies.first,
    );
    final color = Color(featured['color'] as int);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), AppColors.surfaceContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _featuredFloatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _featuredFloatAnim.value * 0.5),
                child: AnimatedBuilder(
                  animation: _featuredGlowAnim,
                  builder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4 * _featuredGlowAnim.value),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      featured['icon'] as IconData,
                      color: color,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eng yaxshi yutuq',
                    style: TextStyle(
                      color: AppColors.outline,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    featured['title'] as String,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    featured['description'] as String,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      featured['rarity'] as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.outline,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        dividerColor: Colors.transparent,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildSeasonalProgress() {
    if (_selectedTab != 3) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mavsumiy progress',
              style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yoz mavsumi 2025',
                  style: TextStyle(color: AppColors.outline, fontSize: 12),
                ),
                const Text(
                  '3/8 yutuq',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.375,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F00)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverGrid _buildTrophyGrid() {
    final items = _filteredTrophies;
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _TrophyCell(trophy: items[index]),
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
    );
  }
}

class _TrophyCell extends StatelessWidget {
  final Map<String, dynamic> trophy;
  const _TrophyCell({required this.trophy});

  @override
  Widget build(BuildContext context) {
    final earned = trophy['earned'] as bool? ?? false;
    final color = Color(trophy['color'] as int? ?? 0xFFADC6FF);
    final icon = trophy['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned
            ? color.withOpacity(0.1)
            : const Color(0xFF1E1E1E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned ? color.withOpacity(0.3) : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: earned ? color.withOpacity(0.2) : AppColors.surfaceContainerHigh,
                ),
                child: Icon(
                  earned ? icon : Icons.lock_outline,
                  color: earned ? color : AppColors.outline,
                  size: 24,
                ),
              ),
              if (earned)
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 9, color: AppColors.onTertiary),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trophy['title'] as String? ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: earned ? AppColors.onSurface : AppColors.outline,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
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
