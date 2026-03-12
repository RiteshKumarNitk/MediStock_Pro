import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:medistock_pro/core/neon_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _sessionKey = 'user_session';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    
    final result = await neonClient.query(
      'SELECT id, email FROM medi_users WHERE email = @email AND password_hash = @password',
      substitutionValues: {'email': email, 'password': hashedPassword},
    );

    if (result.isEmpty) return null;

    final user = {
      'id': result[0][0],
      'email': result[0][1],
    };

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user));

    return user;
  }

  Future<void> signup(String email, String password, String tenantName, String role) async {
    final hashedPassword = _hashPassword(password);
    
    // 1. Create Tenant
    final tenantResult = await neonClient.query(
      'INSERT INTO medi_tenants (name) VALUES (@name) RETURNING id',
      substitutionValues: {'name': tenantName},
    );
    final tenantId = tenantResult[0][0];

    // 2. Create User
    final userResult = await neonClient.query(
      'INSERT INTO medi_users (email, password_hash) VALUES (@email, @password) RETURNING id',
      substitutionValues: {'email': email, 'password': hashedPassword},
    );
    final userId = userResult[0][0];

    // 3. Create Profile
    await neonClient.query(
      'INSERT INTO medi_profiles (id, tenant_id, role) VALUES (@id, @tenant_id, @role)',
      substitutionValues: {
        'id': userId,
        'tenant_id': tenantId,
        'role': role,
      },
    );
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
  }

  Future<String?> getTenantId() async {
    final user = await getCurrentUser();
    if (user == null) return null;

    final result = await neonClient.query(
      'SELECT tenant_id FROM medi_profiles WHERE id = @id',
      substitutionValues: {'id': user['id']},
    );

    if (result.isEmpty) return null;
    return result[0][0].toString();
  }
}
