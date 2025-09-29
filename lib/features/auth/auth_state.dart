import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class AuthState extends ChangeNotifier {
  String? _token;
  bool _loading = false;
  String? _error;

  String? get token => _token;
  bool get isAuthed => _token != null && _token!.isNotEmpty;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadToken() async {
    try {
      final sp = await SharedPreferences.getInstance();
      _token = sp.getString('auth_token');
      print('loadToken: token=$_token');
    } catch (e) {
      print('loadToken error: $e');
      _token = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('auth_token');
    _token = null;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiClient().login(
        username: username,
        password: password,
      );
      if (token == null || token.isEmpty) {
        throw Exception('No token in response');
      }

      final sp = await SharedPreferences.getInstance();
      await sp.setString('auth_token', token);
      _token = token;
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?.toString() ?? e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
