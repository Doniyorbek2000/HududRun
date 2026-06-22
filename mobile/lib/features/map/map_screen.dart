// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../api_service.dart';
import '../../theme_colors.dart';
import 'run_summary_screen.dart';
import 'victory_screen.dart';

class MapScreen extends StatefulWidget {
  final ApiService? apiService;
  const MapScreen({super.key, this.apiService});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;

  Position? _currentPosition;
  bool _isRunning = false;
  bool _isLoading = false;
  final List<LatLng> _runPath = [];
  DateTime? _runStartTime;
  double _totalDistance = 0;
  int _capturedCount = 0;

  List<Map<String, dynamic>> _territories = [];
  bool _territoriesLoaded = false;
  String? _locationError;
  List<String> _stolenFromUsers = [];
  bool _showStolenBanner = false;
  bool _showHeatmap = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const _defaultCenter = LatLng(41.2995, 69.2401); // Tashkent

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initLocation();
    _loadTerritories();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError = 'GPS o\'chiq. Yoqing.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationError = 'Joylashuv ruxsati rad etildi.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationError = 'Joylashuv ruxsatini sozlamalardan bering.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() => _currentPosition = position);
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      }
    } catch (_) {
      setState(() => _locationError = 'Joylashuv aniqlanmadi.');
    }
  }

  Future<void> _loadTerritories() async {
    try {
      final data = await (widget.apiService?.fetchTerritories() ??
          Future.value(<Map<String, dynamic>>[]));
      if (mounted) setState(() { _territories = data; _territoriesLoaded = true; });
    } catch (_) {
      if (mounted) setState(() => _territoriesLoaded = true);
    }
  }

  void _startRun() {
    setState(() {
      _isRunning = true;
      _runPath.clear();
      _totalDistance = 0;
      _capturedCount = 0;
      _runStartTime = DateTime.now();
      _stolenFromUsers = [];
      _showStolenBanner = false;
    });

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) {
      if (!mounted) return;
      final newPoint = LatLng(position.latitude, position.longitude);

      setState(() {
        if (_runPath.isNotEmpty) {
          _totalDistance += const Distance().as(
            LengthUnit.Meter,
            _runPath.last,
            newPoint,
          );
        }
        _runPath.add(newPoint);
        _currentPosition = position;
      });

      _mapController.move(newPoint, _mapController.camera.zoom);
    });
  }

  Future<void> _stopRun() async {
    _positionSub?.cancel();
    _positionSub = null;

    if (_runPath.length < 3) {
      setState(() => _isRunning = false);
      return;
    }

    setState(() { _isRunning = false; _isLoading = true; });

    final endTime = DateTime.now();
    final startTime = _runStartTime ?? endTime;
    final durationSec = endTime.difference(startTime).inSeconds;
    final distKm = _totalDistance / 1000;

    final polygon = [..._runPath, _runPath.first];
    final polygonData = polygon.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
    final routeData = _runPath.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();

    double area = _calculatePolygonAreaKm2(_runPath);

    final prevOwnerSet = <String>{};
    for (final t in _territories) {
      final owner = t['ownerUsername'] as String?;
      if (owner != null) prevOwnerSet.add(owner);
    }

    try {
      await widget.apiService?.claimPolygon(polygonData, area);
      _capturedCount = 1;
    } catch (_) {}

    try {
      await widget.apiService?.saveActivity(
        distance: distKm,
        duration: durationSec,
        startTime: startTime,
        endTime: endTime,
        route: routeData,
      );
    } catch (_) {}

    await _loadTerritories();

    final newOwnerSet = <String>{};
    for (final t in _territories) {
      final owner = t['ownerUsername'] as String?;
      if (owner != null) newOwnerSet.add(owner);
    }
    final stolen = prevOwnerSet.difference(newOwnerSet).toList();
    if (stolen.isNotEmpty) {
      setState(() {
        _stolenFromUsers = stolen.take(5).toList();
        _showStolenBanner = true;
      });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showStolenBanner = false);
      });
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RunSummaryScreen(
          distanceKm: distKm,
          durationSeconds: durationSec,
          territoriesCaptured: _capturedCount,
          caloriesBurned: (distKm * 60).round(),
          pointsEarned: (_capturedCount * 50 + (distKm * 10).round()),
          startTime: startTime,
          endTime: endTime,
        ),
      ),
    );
  }

  double _calculatePolygonAreaKm2(List<LatLng> points) {
    if (points.length < 3) return 0;
    double area = 0;
    const earthRadius = 6371.0; // km
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      final lat1 = points[i].latitudeInRad;
      final lat2 = points[j].latitudeInRad;
      final lng1 = points[i].longitudeInRad;
      final lng2 = points[j].longitudeInRad;
      area += (lng2 - lng1) * (2 + math.sin(lat1) + math.sin(lat2));
    }
    area = (area * earthRadius * earthRadius / 2).abs();
    return area;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          _buildMap(),
          _buildTopStats(),
          if (_showStolenBanner) _buildStolenBanner(),
          if (_locationError != null) _buildLocationError(),
          _buildBottomControls(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.tertiary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultCenter;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
        minZoom: 10,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.hududrun.app',
          maxZoom: 19,
        ),
        if (_showHeatmap)
          // Heatmap of most-run zones (intensity by captured area)
          CircleLayer(circles: _buildHeatmapCircles())
        else ...[
          // Existing territories
          PolygonLayer(
            polygons: _buildTerritoryPolygons(),
          ),
          // Owner avatar markers
          MarkerLayer(
            markers: _buildOwnerMarkers(),
          ),
        ],
        // Current run path
        if (_runPath.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _runPath,
                color: AppColors.tertiary,
                strokeWidth: 4,
                borderColor: AppColors.tertiary.withOpacity(0.3),
                borderStrokeWidth: 8,
              ),
            ],
          ),
        // Run polygon preview
        if (_runPath.length > 2)
          PolygonLayer(
            polygons: [
              Polygon(
                points: _runPath,
                color: AppColors.tertiary.withOpacity(0.2),
                borderColor: AppColors.tertiary,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        // Current location marker
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                width: 60,
                height: 60,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50 * _pulseAnim.value,
                        height: 50 * _pulseAnim.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_isRunning ? AppColors.tertiary : AppColors.primary)
                              .withOpacity(0.2 * _pulseAnim.value),
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRunning ? AppColors.tertiary : AppColors.primary,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRunning ? AppColors.tertiary : AppColors.primary)
                                  .withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Polygon> _buildTerritoryPolygons() {
    final polygons = <Polygon>[];
    for (final territory in _territories) {
      final rawPolygon = territory['polygon'];
      if (rawPolygon == null) continue;

      List<dynamic> points;
      try {
        points = rawPolygon as List<dynamic>;
      } catch (_) {
        continue;
      }

      if (points.length < 3) continue;

      final latlngs = points.map<LatLng>((p) {
        final map = p as Map<String, dynamic>;
        return LatLng(
          (map['lat'] as num).toDouble(),
          (map['lng'] as num).toDouble(),
        );
      }).toList();

      final colorHex = territory['ownerColor'] as String? ?? '#ADC6FF';
      final color = _hexToColor(colorHex);

      polygons.add(Polygon(
        points: latlngs,
        color: color.withOpacity(0.35),
        borderColor: color,
        borderStrokeWidth: 2,
        label: territory['ownerUsername'] as String?,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ));
    }
    return polygons;
  }

  List<CircleMarker> _buildHeatmapCircles() {
    final circles = <CircleMarker>[];
    double maxArea = 0;
    final centroids = <LatLng>[];
    final areas = <double>[];

    for (final territory in _territories) {
      final rawPolygon = territory['polygon'];
      if (rawPolygon == null) continue;
      List<dynamic> points;
      try {
        points = rawPolygon as List<dynamic>;
      } catch (_) {
        continue;
      }
      if (points.length < 3) continue;

      final latlngs = points.map<LatLng>((p) {
        final map = p as Map<String, dynamic>;
        return LatLng((map['lat'] as num).toDouble(), (map['lng'] as num).toDouble());
      }).toList();

      final area = (territory['area'] as num?)?.toDouble() ?? 0.01;
      centroids.add(_polygonCentroid(latlngs));
      areas.add(area);
      if (area > maxArea) maxArea = area;
    }

    for (int i = 0; i < centroids.length; i++) {
      final ratio = maxArea > 0 ? (areas[i] / maxArea).clamp(0.0, 1.0) : 0.0;
      final color = Color.lerp(const Color(0xFFFFD54F), const Color(0xFFFF1744), ratio) ?? Colors.orange;
      final radiusMeters = 60 + ratio * 200;

      circles.add(CircleMarker(
        point: centroids[i],
        radius: radiusMeters,
        useRadiusInMeter: true,
        color: color.withOpacity(0.35),
        borderColor: color.withOpacity(0.6),
        borderStrokeWidth: 1.5,
      ));
    }
    return circles;
  }

  Color _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  LatLng _polygonCentroid(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  List<Marker> _buildOwnerMarkers() {
    final markers = <Marker>[];
    for (final territory in _territories) {
      final rawPolygon = territory['polygon'];
      if (rawPolygon == null) continue;
      List<dynamic> points;
      try {
        points = rawPolygon as List<dynamic>;
      } catch (_) {
        continue;
      }
      if (points.length < 3) continue;

      final latlngs = points.map<LatLng>((p) {
        final map = p as Map<String, dynamic>;
        return LatLng(
          (map['lat'] as num).toDouble(),
          (map['lng'] as num).toDouble(),
        );
      }).toList();

      final center = _polygonCentroid(latlngs);
      final username = territory['ownerUsername'] as String? ?? '?';
      final colorHex = territory['ownerColor'] as String? ?? '#ADC6FF';
      final color = _hexToColor(colorHex);
      final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

      markers.add(Marker(
        point: center,
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ));
    }
    return markers;
  }

  Widget _buildStolenBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Siz ${_stolenFromUsers.length} kishining hududini oldingiz!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _stolenFromUsers.take(5).map((name) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    if (!_isRunning) {
      return Positioned(
        top: 12,
        left: 12,
        right: 12,
        child: SafeArea(
          child: Row(
            children: [
              _StatPill(
                label: 'Hudud',
                value: '${_territories.length}',
                icon: Icons.flag_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Faol',
                value: _territoriesLoaded ? 'Ha' : '...',
                icon: Icons.circle,
                color: AppColors.tertiary,
              ),
              const Spacer(),
              _MapIconButton(
                icon: Icons.local_fire_department,
                active: _showHeatmap,
                onTap: () => setState(() => _showHeatmap = !_showHeatmap),
              ),
              const SizedBox(width: 8),
              _MapIconButton(
                icon: Icons.my_location,
                onTap: () {
                  if (_currentPosition != null) {
                    _mapController.move(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      15.0,
                    );
                  } else {
                    _initLocation();
                  }
                },
              ),
              const SizedBox(width: 8),
              _MapIconButton(
                icon: Icons.refresh,
                onTap: _loadTerritories,
              ),
            ],
          ),
        ),
      );
    }

    // Running mode stats bar
    final elapsed = _runStartTime != null
        ? DateTime.now().difference(_runStartTime!).inSeconds
        : 0;
    final mins = elapsed ~/ 60;
    final secs = elapsed % 60;
    final distKm = (_totalDistance / 1000).toStringAsFixed(2);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tertiary.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiary.withOpacity(0.15),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RunStat(
                label: 'MASOFA',
                value: '$distKm km',
                color: AppColors.primary,
              ),
              Container(width: 1, height: 30, color: Colors.white12),
              _RunStat(
                label: 'VAQT',
                value: '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                color: AppColors.tertiary,
              ),
              Container(width: 1, height: 30, color: Colors.white12),
              _RunStat(
                label: 'NUQTALAR',
                value: '${_runPath.length}',
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationError() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5555).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _locationError!,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            GestureDetector(
              onTap: () { setState(() => _locationError = null); _initLocation(); },
              child: const Icon(Icons.refresh, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRunning && _runPath.length >= 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_runPath.length} nuqta yozildi — davra yoping!',
                  style: TextStyle(
                    color: AppColors.tertiary.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Row(
              children: [
                if (!_isRunning) ...[
                  Expanded(
                    child: _ActionBtn(
                      label: 'Hududlar',
                      icon: Icons.map_outlined,
                      color: AppColors.primary,
                      onTap: _loadTerritories,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : (_isRunning ? _stopRun : _startRun),
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isRunning
                              ? [const Color(0xFFFF5555), const Color(0xFF8B0000)]
                              : [const Color(0xFFFE6B00), const Color(0xFF7A3000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRunning
                                    ? const Color(0xFFFF5555)
                                    : const Color(0xFFFE6B00))
                                .withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRunning ? Icons.stop_rounded : Icons.directions_run,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRunning ? 'TO\'XTATISH' : 'YUGURISH',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_isRunning) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Profil',
                      icon: Icons.person_outline,
                      color: AppColors.secondary,
                      onTap: () {},
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RunStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RunStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            '$label: $value',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _MapIconButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFE6B00).withOpacity(0.25)
              : AppColors.surfaceContainer.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? const Color(0xFFFE6B00) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(icon, color: active ? const Color(0xFFFE6B00) : AppColors.onSurface, size: 18),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
