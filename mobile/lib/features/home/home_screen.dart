import 'package:flutter/material.dart';

import '../../api_service.dart';
import '../../models/user.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../map/map_screen.dart';
import '../notifications/notifications_widget.dart';
import '../premium/premium_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  final User user;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.apiService,
    required this.user,
    required this.onLogout,
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
      setState(() {
        _user = refreshedUser;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to refresh profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1424),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SizedBox(height: 420, child: NotificationsWidget()),
    );
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const MapScreen(),
      const LeaderboardScreen(),
      const PremiumScreen(),
      ProfileScreen(user: _user),
    ];

    final titles = ['Map Battle', 'Rankings', 'Premium', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showNotifications,
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1A2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF304E98),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.run_circle,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${_user.username}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Level ${_user.level} • ${_user.isPremium ? 'Premium member' : 'Free tier'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _refreshProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C7BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Refresh'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF091826),
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        selectedItemColor: const Color(0xFF7B92FF),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Battle'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Rankings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium),
            label: 'Premium',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
