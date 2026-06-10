// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../models/user.dart';
import '../../theme_colors.dart';
import '../challenges/challenges_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../map/map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/notifications_widget.dart';
import '../profile/profile_screen.dart';
import '../squad/squad_settings_screen.dart';
import '../trophies/trophy_room_screen.dart';
import '../../screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  final User user;
  final VoidCallback onLogout;
  final Function(Locale)? onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.apiService,
    required this.user,
    required this.onLogout,
    this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late User _user;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isRefreshing = true;
      _error = null;
    });
    try {
      final refreshedUser = await widget.apiService.fetchProfile();
      setState(() => _user = refreshedUser);
    } catch (_) {
      setState(() => _error = 'Profilni yangilashda xatolik yuz berdi.');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _showNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(apiService: widget.apiService),
      ),
    );
  }

  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onLocaleChanged: widget.onLocaleChanged ?? (_) {},
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index.clamp(0, 3));
  }

  @override
  Widget build(BuildContext context) {
    // 4 actual content screens (no FAB slot needed in list)
    final screenList = <Widget>[
      MapScreen(apiService: widget.apiService),
      LeaderboardScreen(apiService: widget.apiService),
      ChallengesScreen(apiService: widget.apiService),
      const TrophyRoomScreen(),
    ];

    final titleList = ['Xarita', 'Reyting', 'Musobaqalar', 'Yutuqlar'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_run,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              titleList[_selectedIndex],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        actions: [
          // User XP chip
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Lv ${_user.level}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SquadSettingsScreen(apiService: widget.apiService)),
            ),
            icon: const Icon(Icons.group_outlined),
            tooltip: 'Jamoa',
          ),
          IconButton(
            onPressed: _showNotifications,
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Sozlamalar',
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // User stats header card
          _buildUserCard(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          Expanded(child: screenList[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildRunFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    user: _user,
                    apiService: widget.apiService,
                  ),
                ),
              );
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _user.username.isNotEmpty
                      ? _user.username.substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user.username,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Daraja ${_user.level} • ${_user.isPremium ? 'Premium' : 'Oddiy'}',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _refreshProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    // 5 items: Map, Rankings, [FAB spacer], Challenges, Trophies
    // But we use BottomAppBar + FAB pattern
    return BottomAppBar(
      color: AppColors.surfaceContainerLowest,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.map_outlined,
              activeIcon: Icons.map,
              label: 'Xarita',
              isActive: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _NavItem(
              icon: Icons.leaderboard_outlined,
              activeIcon: Icons.leaderboard,
              label: 'Reyting',
              isActive: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 40), // FAB spacer
            _NavItem(
              icon: Icons.emoji_events_outlined,
              activeIcon: Icons.emoji_events,
              label: 'Musobaqa',
              isActive: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _NavItem(
              icon: Icons.workspace_premium_outlined,
              activeIcon: Icons.workspace_premium,
              label: 'Yutuqlar',
              isActive: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunFAB() {
    return GestureDetector(
      onTap: () {
        // Navigate to run/map screen
        setState(() => _selectedIndex = 0);
      },
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFE6B00), Color(0xFF7A3000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4DFE6B00),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_run,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.outline,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.outline,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
