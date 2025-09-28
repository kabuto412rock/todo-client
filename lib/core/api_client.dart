import 'dart:convert';

import 'package:dio/dio.dart';
import 'env.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final resp = await this._dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = resp.data is Map ? resp.data : jsonDecode(resp.data);
    final token = data['token'] as String?;
    return token;
  }
}
