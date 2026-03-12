import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';

class NeonClient {
  static final NeonClient _instance = NeonClient._internal();
  factory NeonClient() => _instance;
  NeonClient._internal();

  Connection? _connection;

  // Placeholder for Neon credentials - User should replace these
  static const String _host = 'ep-cool-water-a5m0.us-east-2.aws.neon.tech';
  static const String _database = 'neondb';
  static const String _username = 'neondb_owner';
  static const String _password = 'USER_MUST_PROVIDE_PASSWORD';

  Future<Connection> get connection async {
    if (_connection != null && !_connection!.isOpen) {
      _connection = null;
    }

    if (_connection == null) {
      _connection = await Connection.open(
        Endpoint(
          host: _host,
          database: _database,
          username: _username,
          password: _password,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.require,
        ),
      );
      debugPrint('Connected to Neon DB');
    }
    return _connection!;
  }

  Future<Result> query(String sql, {Map<String, dynamic>? substitutionValues}) async {
    final conn = await connection;
    return await conn.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}

final neonClient = NeonClient();
