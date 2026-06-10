// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme_colors.dart';

class FriendsScreen extends StatefulWidget {
  final ApiService apiService;
  const FriendsScreen({super.key, required this.apiService});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pending = [];
  bool _loadingFriends = true;
  bool _loadingPending = true;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _adding = false;
  String? _addError;
  String? _addSuccess;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFriends();
    _loadPending();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final data = await widget.apiService.fetchFriends();
      if (mounted) setState(() { _friends = data; _loadingFriends = false; });
    } catch (_) {
      if (mounted) setState(() {
        _friends = _mockFriends();
        _loadingFriends = false;
      });
    }
  }

  Future<void> _loadPending() async {
    try {
      final data = await widget.apiService.fetchPendingRequests();
      if (mounted) setState(() { _pending = data; _loadingPending = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPending = false);
    }
  }

  Future<void> _sendRequest() async {
    final username = _searchCtrl.text.trim();
    if (username.isEmpty) return;
    setState(() { _adding = true; _addError = null; _addSuccess = null; });
    try {
      await widget.apiService.sendFriendRequest(username);
      if (mounted) {
        setState(() { _addSuccess = "'$username' ga so'rov yuborildi!"; _adding = false; });
        _searchCtrl.clear();
      }
    } catch (e) {
      if (mounted) setState(() { _addError = 'Foydalanuvchi topilmadi yoki so\'rov yuborilmadi.'; _adding = false; });
    }
  }

  Future<void> _acceptRequest(String friendId, int index) async {
    try {
      await widget.apiService.acceptFriendRequest(friendId);
      setState(() => _pending.removeAt(index));
      _loadFriends();
    } catch (_) {}
  }

  Future<void> _removeFriend(String friendId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text("Do'stni o'chirish", style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
        content: const Text("Haqiqatan ham bu do'stni o'chirmoqchimisiz?", style: TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("O'chirish", style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.apiService.removeFriend(friendId);
      setState(() => _friends.removeAt(index));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: const Text(
          "DO'STLAR",
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.outline,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: "DO'STLAR (${_friends.length})"),
            Tab(text: _pending.isEmpty ? "SO'ROVLAR" : "SO'ROVLAR (${_pending.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Add friend bar
          _buildAddFriendBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildPendingList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFriendBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: "Foydalanuvchi nomi kiriting...",
                    hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
                    prefixIcon: const Icon(Icons.person_search, color: AppColors.outline, size: 20),
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _sendRequest(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _adding ? null : _sendRequest,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFE6B00), Color(0xFF7A3000)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _adding
                      ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.person_add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          if (_addError != null) ...[
            const SizedBox(height: 6),
            Text(_addError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          if (_addSuccess != null) ...[
            const SizedBox(height: 6),
            Text(_addSuccess!, style: const TextStyle(color: AppColors.tertiary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_loadingFriends) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_friends.isEmpty) return _buildEmpty("Hali do'stlaringiz yo'q");
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (_, i) {
        final f = _friends[i];
        final name = f['username'] as String? ?? f['friend']?['username'] as String? ?? 'User';
        final level = f['level'] as int? ?? f['friend']?['level'] as int? ?? 1;
        final xp = f['xp'] as int? ?? f['friend']?['xp'] as int? ?? 0;
        final color = Color(int.tryParse((f['color'] as String? ?? '#ADC6FF').replaceFirst('#', '0xFF')) ?? 0xFFADC6FF);
        final id = f['id'] as String? ?? f['friendId'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.2),
                child: Text(name.substring(0, 1), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('Daraja $level • $xp XP', style: const TextStyle(color: AppColors.outline, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_remove_outlined, color: AppColors.error, size: 20),
                onPressed: () => _removeFriend(id, i),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingList() {
    if (_loadingPending) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_pending.isEmpty) return _buildEmpty("Kutilayotgan so'rovlar yo'q");
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pending.length,
      itemBuilder: (_, i) {
        final p = _pending[i];
        final name = p['username'] as String? ?? p['user']?['username'] as String? ?? 'User';
        final id = p['id'] as String? ?? p['userId'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(name.substring(0, 1), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              TextButton(
                onPressed: () => _acceptRequest(id, i),
                child: const Text('Qabul', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.people_outline, color: AppColors.outline, size: 56),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: AppColors.outline, fontSize: 14)),
      ],
    ),
  );

  List<Map<String, dynamic>> _mockFriends() => [
    {'id': '1', 'username': 'NovaPulse', 'level': 10, 'xp': 3900, 'color': '#2563EB'},
    {'id': '2', 'username': 'Vortex', 'level': 9, 'xp': 3200, 'color': '#059669'},
  ];
}
