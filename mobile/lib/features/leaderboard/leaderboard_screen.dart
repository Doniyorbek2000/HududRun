// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme_colors.dart';
import '../../l10n/app_localizations.dart';

class LeaderboardScreen extends StatefulWidget {
  final ApiService apiService;
  const LeaderboardScreen({super.key, required this.apiService});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Individual tab state
  int _geoFilter = 0; // 0=Global, 1=Davlat, 2=Viloyat, 3=Tuman
  List<Map<String, dynamic>> _individuals = [];
  bool _loadingIndividuals = true;
  String? _filterCountry;
  String? _filterRegion;
  String? _filterDistrict;

  // Squad tab state
  List<Map<String, dynamic>> _squads = [];
  bool _loadingSquads = true;
  bool _squadsLoaded = false;

  // Weekly tab state
  List<Map<String, dynamic>> _weekly = [];
  bool _loadingWeekly = true;
  bool _weeklyLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_squadsLoaded) _loadSquads();
      if (_tabController.index == 2 && !_weeklyLoaded) _loadWeekly();
    });
    _loadIndividuals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadIndividuals() async {
    setState(() => _loadingIndividuals = true);
    try {
      final data = await widget.apiService.fetchLeaderboardFiltered(
        country: _geoFilter >= 1 ? _filterCountry : null,
        region: _geoFilter >= 2 ? _filterRegion : null,
        district: _geoFilter >= 3 ? _filterDistrict : null,
      );
      if (mounted) setState(() { _individuals = data; _loadingIndividuals = false; });
    } catch (_) {
      if (mounted) setState(() { _individuals = _mockIndividuals(); _loadingIndividuals = false; });
    }
  }

  Future<void> _loadSquads() async {
    setState(() => _loadingSquads = true);
    try {
      final data = await widget.apiService.fetchSquadLeaderboard();
      if (mounted) setState(() { _squads = data; _loadingSquads = false; _squadsLoaded = true; });
    } catch (_) {
      if (mounted) setState(() { _squads = _mockSquads(); _loadingSquads = false; _squadsLoaded = true; });
    }
  }

  Future<void> _loadWeekly() async {
    setState(() => _loadingWeekly = true);
    try {
      final data = await widget.apiService.fetchWeeklyLeaderboard();
      if (mounted) setState(() { _weekly = data; _loadingWeekly = false; _weeklyLoaded = true; });
    } catch (_) {
      if (mounted) setState(() { _weekly = _mockWeekly(); _loadingWeekly = false; _weeklyLoaded = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Tab bar
        Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'YAKKA'),
              Tab(text: 'JAMOALAR'),
              Tab(text: 'HAFTALIK'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIndividualTab(l10n),
              _buildSquadTab(l10n),
              _buildWeeklyTab(l10n),
            ],
          ),
        ),
      ],
    );
  }

  // ── Individual Tab ────────────────────────────────────────────────────────

  Widget _buildIndividualTab(AppLocalizations l10n) {
    return Column(
      children: [
        // Geo filter chips
        _buildGeoFilterBar(),
        // If filter requires input, show text fields
        if (_geoFilter >= 1) _buildGeoInputs(),
        Expanded(
          child: _loadingIndividuals
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildIndividualList(),
        ),
      ],
    );
  }

  Widget _buildGeoFilterBar() {
    const labels = ['🌍 Global', '🗺 Davlat', '📍 Viloyat', '🏘 Tuman'];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _geoFilter == i;
          return GestureDetector(
            onTap: () {
              setState(() { _geoFilter = i; });
              _loadIndividuals();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeoInputs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          if (_geoFilter >= 1)
            Expanded(child: _GeoTextField(
              hint: 'Davlat kodi (UZ)',
              value: _filterCountry,
              onChanged: (v) { _filterCountry = v.isEmpty ? null : v.toUpperCase(); },
              onSubmit: _loadIndividuals,
            )),
          if (_geoFilter >= 2) ...[
            const SizedBox(width: 8),
            Expanded(child: _GeoTextField(
              hint: 'Viloyat',
              value: _filterRegion,
              onChanged: (v) { _filterRegion = v.isEmpty ? null : v; },
              onSubmit: _loadIndividuals,
            )),
          ],
          if (_geoFilter >= 3) ...[
            const SizedBox(width: 8),
            Expanded(child: _GeoTextField(
              hint: 'Tuman',
              value: _filterDistrict,
              onChanged: (v) { _filterDistrict = v.isEmpty ? null : v; },
              onSubmit: _loadIndividuals,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildIndividualList() {
    if (_individuals.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _individuals.length,
      itemBuilder: (_, i) {
        final u = _individuals[i];
        final rank = u['rank'] as int? ?? i + 1;
        if (rank <= 3) return _PodiumCard(data: u, rank: rank);
        return _LeaderRow(data: u, rank: rank);
      },
    );
  }

  // ── Squad Tab ─────────────────────────────────────────────────────────────

  Widget _buildSquadTab(AppLocalizations l10n) {
    if (_loadingSquads) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_squads.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _squads.length,
      itemBuilder: (_, i) {
        final s = _squads[i];
        final rank = s['rank'] as int? ?? i + 1;
        return _SquadRow(data: s, rank: rank);
      },
    );
  }

  // ── Weekly Tab ────────────────────────────────────────────────────────────

  Widget _buildWeeklyTab(AppLocalizations l10n) {
    if (_loadingWeekly) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_weekly.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _weekly.length,
      itemBuilder: (_, i) {
        final u = _weekly[i];
        final rank = u['rank'] as int? ?? i + 1;
        return _WeeklyRow(data: u, rank: rank);
      },
    );
  }

  Widget _buildEmpty() => const Center(
    child: Text('Ma\'lumot topilmadi', style: TextStyle(color: AppColors.outline)),
  );

  // ── Mock data ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _mockIndividuals() => [
    {'rank': 1, 'username': 'ShadowRunner', 'level': 12, 'xp': 4800, 'territoryCount': 23, 'color': '#7C3AED', 'country': 'UZ', 'region': 'Toshkent'},
    {'rank': 2, 'username': 'NovaPulse', 'level': 10, 'xp': 3900, 'territoryCount': 18, 'color': '#2563EB', 'country': 'UZ', 'region': 'Toshkent'},
    {'rank': 3, 'username': 'Vortex', 'level': 9, 'xp': 3200, 'territoryCount': 14, 'color': '#059669', 'country': 'UZ', 'region': 'Samarqand'},
    {'rank': 4, 'username': 'EchoStorm', 'level': 8, 'xp': 2600, 'territoryCount': 11, 'color': '#D97706', 'country': 'UZ', 'region': 'Andijon'},
    {'rank': 5, 'username': 'PhantomX', 'level': 7, 'xp': 2100, 'territoryCount': 8, 'color': '#DC2626', 'country': 'UZ', 'region': 'Farg\'ona'},
  ];

  List<Map<String, dynamic>> _mockSquads() => [
    {'rank': 1, 'name': 'Shadow Runners', 'tag': 'SR', 'color': '#7C3AED', 'captainName': 'ShadowRunner', 'memberCount': 5, 'totalXp': 18400, 'totalTerritories': 74},
    {'rank': 2, 'name': 'Nova Squad', 'tag': 'NS', 'color': '#2563EB', 'captainName': 'NovaPulse', 'memberCount': 4, 'totalXp': 14200, 'totalTerritories': 55},
    {'rank': 3, 'name': 'Storm Force', 'tag': 'SF', 'color': '#059669', 'captainName': 'Vortex', 'memberCount': 6, 'totalXp': 11800, 'totalTerritories': 48},
  ];

  List<Map<String, dynamic>> _mockWeekly() => [
    {'rank': 1, 'username': 'SprintKing', 'level': 8, 'weeklyDistance': 42.3, 'runCount': 6, 'color': '#F59E0B'},
    {'rank': 2, 'username': 'DawnRacer', 'level': 6, 'weeklyDistance': 38.1, 'runCount': 5, 'color': '#7C3AED'},
    {'rank': 3, 'username': 'ShadowRunner', 'level': 12, 'weeklyDistance': 35.7, 'runCount': 7, 'color': '#2563EB'},
  ];
}

// ── Reusable widgets ─────────────────────────────────────────────────────────

class _PodiumCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int rank;
  const _PodiumCard({required this.data, required this.rank});

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final podiumColor = colors[rank - 1];
    final userColor = Color(int.tryParse((data['color'] as String? ?? '#ADC6FF').replaceFirst('#', '0xFF')) ?? 0xFFADC6FF);
    final name = data['username'] as String? ?? 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: podiumColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: podiumColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          // Rank medal
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: podiumColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: userColor.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0] : 'U',
              style: TextStyle(color: userColor, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  'Daraja ${data['level']} • ${data['territoryCount'] ?? 0} hudud',
                  style: const TextStyle(color: AppColors.outline, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data['xp']} XP',
                style: TextStyle(color: podiumColor, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              if (data['region'] != null)
                Text(
                  data['region'] as String,
                  style: const TextStyle(color: AppColors.outline, fontSize: 10),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final int rank;
  const _LeaderRow({required this.data, required this.rank});

  @override
  Widget build(BuildContext context) {
    final userColor = Color(int.tryParse((data['color'] as String? ?? '#ADC6FF').replaceFirst('#', '0xFF')) ?? 0xFFADC6FF);
    final name = data['username'] as String? ?? 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: const TextStyle(color: AppColors.outline, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: userColor.withOpacity(0.2),
            child: Text(name.isNotEmpty ? name[0] : 'U', style: TextStyle(color: userColor, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                if (data['region'] != null)
                  Text(data['region'] as String, style: const TextStyle(color: AppColors.outline, fontSize: 10)),
              ],
            ),
          ),
          Text('${data['xp']} XP', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 8),
          Text('Lv ${data['level']}', style: const TextStyle(color: AppColors.outline, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SquadRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final int rank;
  const _SquadRow({required this.data, required this.rank});

  @override
  Widget build(BuildContext context) {
    final squadColor = Color(int.tryParse((data['color'] as String? ?? '#ADC6FF').replaceFirst('#', '0xFF')) ?? 0xFFADC6FF);
    final name = data['name'] as String? ?? 'Squad';
    final tag = data['tag'] as String? ?? '';
    final captain = data['captainName'] as String? ?? '';
    final members = data['memberCount'] as int? ?? 0;
    final xp = data['totalXp'] as int? ?? 0;
    final territories = data['totalTerritories'] as int? ?? 0;
    final medalEmojis = ['🥇', '🥈', '🥉'];
    final isMedal = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMedal ? squadColor.withOpacity(0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMedal ? squadColor.withOpacity(0.35) : AppColors.outlineVariant,
          width: isMedal ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank + squad shield
          Column(
            children: [
              Text(isMedal ? medalEmojis[rank - 1] : '$rank', style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(width: 12),
          // Squad icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: squadColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                tag.isNotEmpty ? tag.substring(0, tag.length.clamp(0, 2)) : (name.isNotEmpty ? name[0] : 'S'),
                style: TextStyle(color: squadColor, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Kapitan: $captain • $members a\'zo', style: const TextStyle(color: AppColors.outline, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$xp XP', style: TextStyle(color: squadColor, fontWeight: FontWeight.w800, fontSize: 14)),
              Text('$territories hudud', style: const TextStyle(color: AppColors.outline, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final int rank;
  const _WeeklyRow({required this.data, required this.rank});

  @override
  Widget build(BuildContext context) {
    final userColor = Color(int.tryParse((data['color'] as String? ?? '#F59E0B').replaceFirst('#', '0xFF')) ?? 0xFFF59E0B);
    final name = data['username'] as String? ?? 'User';
    final dist = data['weeklyDistance'];
    final km = dist is double ? dist : (dist as num?)?.toDouble() ?? 0.0;
    final runs = data['runCount'] as int? ?? 0;
    final medalEmojis = ['🥇', '🥈', '🥉'];
    final isMedal = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMedal ? userColor.withOpacity(0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isMedal ? userColor.withOpacity(0.3) : AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Text(isMedal ? medalEmojis[rank - 1] : '$rank', style: TextStyle(fontSize: isMedal ? 20 : 13, color: AppColors.outline, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: userColor.withOpacity(0.2),
            child: Text(name.isNotEmpty ? name[0] : 'U', style: TextStyle(color: userColor, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                Text('$runs yugurish', style: const TextStyle(color: AppColors.outline, fontSize: 10)),
              ],
            ),
          ),
          Text('${km.toStringAsFixed(1)} km', style: TextStyle(color: userColor, fontWeight: FontWeight.w800, fontSize: 15)),
        ],
      ),
    );
  }
}

class _GeoTextField extends StatelessWidget {
  final String hint;
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const _GeoTextField({required this.hint, this.value, required this.onChanged, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        style: const TextStyle(color: AppColors.onSurface, fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 11),
          filled: true,
          fillColor: AppColors.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        onChanged: onChanged,
        onSubmitted: (_) => onSubmit(),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
