import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final _storage = const FlutterSecureStorage();
  final urlApi = 'https://enquete-online-api-production.up.railway.app/api';

  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final token = await _storage.read(key: 'accessToken');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$urlApi/$endpoint').replace(
      queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())),
    );

    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await _storage.read(key: 'accessToken');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return http.post(
      Uri.parse('$urlApi/$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
