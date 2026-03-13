import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/medistock';
    }
    // Android emulator loopback IP. 
    // If using a physical device, change this to your computer's IP (e.g., 192.168.31.67)
    return 'http://10.0.2.2:3000/api/medistock';
  }
  
  static Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: await _headers);
  }

  static Future<http.Response> post(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url, 
      headers: await _headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url, 
      headers: await _headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: await _headers);
  }
}
