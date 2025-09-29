import 'dart:convert';

import 'package:dio/dio.dart';
import 'env.dart';
import 'package:todo_client/features/todos/todo_model.dart';

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
    final resp = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = resp.data is Map ? resp.data : jsonDecode(resp.data);
    final token = data['token'] as String?;
    return token;
  }

  Future<List<Todo>> getTodoList({required String token}) async {
    final resp = await _dio.get(
      '/todos',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final dynamic data = resp.data is String
        ? jsonDecode(resp.data)
        : resp.data;

    // Accept either a plain list or an object with a `data` list
    final List<dynamic> rawList = data is List
        ? data
        : (data is Map<String, dynamic> && data['todos'] is List
              ? data['todos'] as List
              : <dynamic>[]);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => Todo.fromJson(e))
        .toList(growable: false);
  }

  /// Create a new todo item by title.
  /// Accepts responses shaped as either a plain todo object or
  /// an envelope like { "todo": { ... } }.
  Future<Todo> createTodo({
    required String token,
    required String title,
    bool done = false,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'done': done,
      if (dueDate != null) 'dueDate': dueDate.toUtc().toIso8601String(),
    };

    final resp = await _dio.post(
      '/todos',
      data: jsonEncode(body),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final dynamic data = resp.data is String
        ? jsonDecode(resp.data)
        : resp.data;

    final Map<String, dynamic>? todoMap = data is Map<String, dynamic>
        ? (data['todo'] is Map<String, dynamic>
              ? data['todo'] as Map<String, dynamic>
              : data)
        : null;

    if (todoMap == null) {
      throw Exception('Unexpected createTodo response: ${resp.data}');
    }
    return Todo.fromJson(todoMap);
  }

  /// Delete a todo by id.
  /// Returns true if the server responds with 200-299.
  Future<bool> deleteTodo({
    required String token,
    required String id,
  }) async {
    final resp = await _dio.delete(
      '/todos/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return resp.statusCode != null && resp.statusCode! ~/ 100 == 2;
  }

  /// Update a todo by id. Sends only provided fields (PATCH style).
  /// Accepts responses shaped as either a plain todo object or
  /// an envelope like { "todo": { ... } }.
  Future<Todo> updateTodo({
    required String token,
    required String id,
    String? title,
    bool? done,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (done != null) body['done'] = done;
    if (dueDate != null) body['dueDate'] = dueDate.toUtc().toIso8601String();

    final resp = await _dio.patch(
      '/todos/$id',
      data: jsonEncode(body),
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    final dynamic data = resp.data is String
        ? jsonDecode(resp.data)
        : resp.data;

    final Map<String, dynamic>? todoMap = data is Map<String, dynamic>
        ? (data['todo'] is Map<String, dynamic>
              ? data['todo'] as Map<String, dynamic>
              : data)
        : null;

    if (todoMap == null) {
      throw Exception('Unexpected updateTodo response: ${resp.data}');
    }
    return Todo.fromJson(todoMap);
  }
}
