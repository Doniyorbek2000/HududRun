import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/user.dart';

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
      final user = await widget.apiService.fetchProfile();
      setState(() {
        _user = user;
      });
    } catch (error) {
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

  Future<void> _logout() async {
    await widget.apiService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HududRun Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshProfile,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Username', _user.username),
                    const SizedBox(height: 8),
                    _buildInfoRow('Phone', _user.phone ?? 'Not provided'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Level', _user.level.toString()),
                    const SizedBox(height: 8),
                    _buildInfoRow('XP', _user.xp.toString()),
                    const SizedBox(height: 8),
                    _buildInfoRow('Premium', _user.isPremium ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_isRefreshing) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: _logout, child: const Text('Logout')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(child: Text(value, textAlign: TextAlign.right)),
      ],
    );
  }
}
