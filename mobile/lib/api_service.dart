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

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _post('/auth/logout', {'refreshToken': refreshToken});
    }
    await clearTokens();
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
