import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'models/user.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<User> login(String username, String password) async {
    final response = await _post('/auth/login', {
      'username': username,
      'password': password,
    });
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    await saveTokens(
      body['accessToken'] as String,
      body['refreshToken'] as String,
    );
    return fetchProfile();
  }

  Future<User> register(String username, String phone, String password) async {
    final response = await _post('/auth/register', {
      'username': username,
      'phone': phone,
      'password': password,
    });
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    await saveTokens(
      body['accessToken'] as String,
      body['refreshToken'] as String,
    );
    return fetchProfile();
  }

  Future<User> fetchProfile() async {
    final response = await _authenticatedGet('/users/me');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(body);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _authenticatedPatch('/users/me', data);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchTerritoryStats() async {
    final response = await _authenticatedGet('/users/me/territory-stats');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _post('/auth/logout', {'refreshToken': refreshToken});
    }
    await clearTokens();
  }

  // ── Leaderboard ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final response = await _authenticatedGet('/users/leaderboard');
    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchWeeklyLeaderboard() async {
    final response = await _authenticatedGet('/users/leaderboard/weekly');
    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboardFiltered({
    String? country,
    String? region,
    String? district,
  }) async {
    final params = <String, String>{};
    if (country != null) params['country'] = country;
    if (region != null) params['region'] = region;
    if (district != null) params['district'] = district;
    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';
    final response = await _authenticatedGet('/users/leaderboard$query');
    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchSquadLeaderboard() async {
    try {
      return await _authenticatedGetList('/users/leaderboard/squads');
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchCurrentWar() async {
    final response = await _authenticatedGet('/squad-wars/current');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchSquadWarHistory() async {
    try {
      return await _authenticatedGetList('/squad-wars/history');
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> shieldTerritory(String h3Index) async {
    final response = await _authenticatedPost('/territories/shield', {'h3Index': h3Index});
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Activities ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> saveActivity({
    required double distance,
    required int duration,
    required DateTime startTime,
    required DateTime endTime,
    List<Map<String, dynamic>>? route,
  }) async {
    final response = await _authenticatedPost('/activities', {
      'distance': distance,
      'duration': duration,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      if (route != null) 'route': route,
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchActivities() async {
    final response = await _authenticatedGet('/activities/me');
    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>();
  }

  // ── Territories ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> claimTerritory(String h3Index) async {
    final response = await _authenticatedPost('/territories/claim', {
      'h3Index': h3Index,
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> claimPolygon(
      List<Map<String, dynamic>> polygon, double area) async {
    final response = await _authenticatedPost('/territories/claim', {
      'h3Index': 'poly_${DateTime.now().millisecondsSinceEpoch}',
      'polygon': polygon,
      'area': area,
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchTerritories() async {
    try {
      return await _authenticatedGetList('/territories');
    } catch (_) {
      return [];
    }
  }

  // ── Challenges ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchChallenges() async {
    try {
      return await _authenticatedGetList('/challenges/me');
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _authenticatedGetList(String path) async {
    final response = await _authenticatedGet(path);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ── Friends ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    final response = await _authenticatedGet('/friends');
    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>();
  }

  Future<void> sendFriendRequest(String targetUsername) async {
    await _authenticatedPost('/friends/request', {'username': targetUsername});
  }

  Future<void> acceptFriendRequest(String friendId) async {
    await _authenticatedPost('/friends/accept', {'friendId': friendId});
  }

  Future<void> removeFriend(String friendId) async {
    await _authenticatedPost('/friends/remove', {'friendId': friendId});
  }

  Future<List<Map<String, dynamic>>> fetchPendingRequests() async {
    try {
      return await _authenticatedGetList('/friends/pending');
    } catch (_) {
      return [];
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      return await _authenticatedGetList('/notifications/me');
    } catch (_) {
      return [];
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _authenticatedPost('/notifications/read-all', {});
    } catch (_) {}
  }

  // ── Squad API ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchSquads() async {
    try {
      return _authenticatedGetList('/squads');
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchMySquad() async {
    try {
      final response = await _authenticatedGet('/squads/my');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body == null) return null;
        return body as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> createSquad(
      String name, String tag, bool isPublic) async {
    final response = await _authenticatedPost('/squads', {
      'name': name,
      'tag': tag,
      'isPublic': isPublic,
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> joinSquad(String squadId) async {
    await _authenticatedPost('/squads/$squadId/join', {});
  }

  Future<void> leaveSquad(String squadId) async {
    await _authenticatedDelete('/squads/$squadId/leave');
  }

  // ── Payments ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createPayment(String plan, String provider) async {
    final response = await _authenticatedPost('/payments', {
      'plan': plan,
      'provider': provider,
    });
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    final response = await _authenticatedGet('/payments/$paymentId/status');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchPayments() async {
    try {
      return await _authenticatedGetList('/payments/me');
    } catch (_) {
      return [];
    }
  }

  // ── Authenticated POST ────────────────────────────────────────────────────

  Future<http.Response> _authenticatedPatch(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _withAuth((headers) async {
      return http.patch(
        Uri.parse('$baseUrl$path'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> _authenticatedPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _withAuth((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    });
    _throwOnError(response);
    return response;
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    final response = await http.post(
      uri,
      headers: mergedHeaders,
      body: jsonEncode(body),
    );
    _throwOnError(response);
    return response;
  }

  Future<http.Response> _authenticatedDelete(String path) async {
    final response = await _withAuth((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.delete(uri, headers: headers);
    });
    _throwOnError(response);
    return response;
  }

  Future<http.Response> _authenticatedGet(String path) async {
    final response = await _withAuth((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.get(uri, headers: headers);
    });
    _throwOnError(response);
    return response;
  }

  Future<http.Response> _withAuth(
    Future<http.Response> Function(Map<String, String>) request,
  ) async {
    final accessToken = await _storage.read(key: 'accessToken');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
    var response = await request(headers);
    if (response.statusCode == 401) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        final newAccessToken = await _storage.read(key: 'accessToken');
        final retryHeaders = <String, String>{
          'Content-Type': 'application/json',
          if (newAccessToken != null && newAccessToken.isNotEmpty)
            'Authorization': 'Bearer $newAccessToken',
        };
        response = await request(retryHeaders);
      }
    }
    return response;
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final uri = Uri.parse('$baseUrl/auth/refresh');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200) {
      await clearTokens();
      return false;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    await _storage.write(
      key: 'accessToken',
      value: body['accessToken'] as String,
    );
    return true;
  }

  void _throwOnError(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
