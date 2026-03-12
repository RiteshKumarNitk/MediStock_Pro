import 'dart:convert';
import 'package:medistock_pro/core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _sessionKey = 'user_session';
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final user = data['user'];
    final token = data['token'];

    // Save session and token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user));
    await prefs.setString(_tokenKey, token);

    return user;
  }

  Future<void> signup(String email, String password, String tenantName, String role) async {
    final response = await ApiClient.post('/auth/register', {
      'email': email,
      'password': password,
      'tenantName': tenantName,
      'role': role,
      'name': email.split('@')[0], // Basic name from email
    });

    if (response.statusCode != 201) {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_sessionKey);
    if (session == null) return null;
    return jsonDecode(session);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }

  Future<String?> getTenantId() async {
    final user = await getCurrentUser();
    if (user == null) return null;
    
    // In our new architecture, tenant info is already in the profile object within user
    if (user['mediProfile'] != null) {
      return user['mediProfile']['tenantId'].toString();
    }
    return null;
  }
}
